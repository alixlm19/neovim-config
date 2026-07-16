-- Automatic + manual Python virtualenv detection for the pyright LSP.
--
-- detect(root)  -> resolves the python interpreter for a project root
-- apply(python) -> points running pyright clients at a python and re-analyzes
-- pick()        -> snacks.picker over venvs found under the cwd (manual override)

local M = {}

-- Directory names we treat as in-project virtualenvs, in priority order.
local VENV_DIRS = { ".venv", "venv", "env", ".env" }

local function python_in(venv_dir)
	-- Support both unix (bin/python) and windows (Scripts/python.exe) layouts.
	for _, rel in ipairs({ "/bin/python", "/Scripts/python.exe" }) do
		local p = venv_dir .. rel
		if vim.fn.executable(p) == 1 then
			return p
		end
	end
end

--- Resolve the interpreter for a project root, walking upward to handle monorepos.
--- Priority: $VIRTUAL_ENV (an already-activated shell venv) > in-project venv > system python3.
---@param root string|nil project root dir; defaults to cwd
---@return string python_path
function M.detect(root)
	root = root or vim.fn.getcwd()

	local active = os.getenv("VIRTUAL_ENV")
	if active and python_in(active) then
		return python_in(active)
	end

	-- Look for a venv directory at `root` or any parent (e.g. monorepo top-level .venv).
	local hits = vim.fs.find(VENV_DIRS, { path = root, upward = true, type = "directory", limit = math.huge })
	for _, venv_dir in ipairs(hits) do
		local py = python_in(venv_dir)
		if py then
			return py
		end
	end

	return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or "python"
end

--- Point running pyright + ruff clients at `python_path` and trigger re-analysis.
---@param python_path string
function M.apply(python_path)
	local found = false

	for _, client in ipairs(vim.lsp.get_clients({ name = "pyright" })) do
		found = true
		client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
			python = { pythonPath = python_path },
		})
		client:notify("workspace/didChangeConfiguration", { settings = client.settings })
	end

	-- ruff resolves first-party imports / target version from this interpreter.
	for _, client in ipairs(vim.lsp.get_clients({ name = "ruff" })) do
		found = true
		client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
			interpreter = { python_path },
		})
		client:notify("workspace/didChangeConfiguration", { settings = client.settings })
	end

	if found then
		vim.notify("Python interpreter → " .. python_path, vim.log.levels.INFO, { title = "venv" })
	else
		vim.notify("No active pyright/ruff client to update", vim.log.levels.WARN, { title = "venv" })
	end
end

--- The interpreter the active pyright client is currently using, or nil.
---@return string|nil
function M.current()
	for _, client in ipairs(vim.lsp.get_clients({ name = "pyright" })) do
		local py = vim.tbl_get(client, "settings", "python", "pythonPath")
		if py then
			return py
		end
	end
end

--- A short, friendly label for the active venv (for the statusline), or nil.
--- e.g. "myproject/.venv", or the env name for named/global venvs.
---@return string|nil
function M.name()
	local py = M.current()
	if not py then
		return nil
	end
	local root = vim.fn.fnamemodify(py, ":h:h") -- strip trailing /bin/python
	local base = vim.fn.fnamemodify(root, ":t")
	if vim.tbl_contains(VENV_DIRS, base) then
		-- Generic dir name; prefix the project dir for context.
		return vim.fn.fnamemodify(root, ":h:t") .. "/" .. base
	end
	return base
end

--- Find candidate venvs under the cwd using `fd`, then choose one via snacks.picker.
function M.pick()
	if vim.fn.executable("fd") == 0 then
		vim.notify("`fd` not found on PATH", vim.log.levels.ERROR, { title = "venv" })
		return
	end

	local cwd = vim.fn.getcwd()
	-- Match any directory named like a venv, a few levels deep.
	local names = {}
	for _, n in ipairs(VENV_DIRS) do
		table.insert(names, "^" .. vim.pesc(n) .. "$")
	end

	-- fd takes a single regex pattern; OR the venv names together.
	local cmd = {
		"fd",
		"--type", "directory",
		"--hidden",
		"--no-ignore-vcs",
		"--max-depth", "6",
		"--absolute-path",
		table.concat(names, "|"),
		cwd,
	}

	local out = vim.fn.systemlist(cmd)
	if vim.v.shell_error ~= 0 then
		vim.notify("fd failed: " .. table.concat(out, "\n"), vim.log.levels.ERROR, { title = "venv" })
		return
	end

	local items = {}
	for _, dir in ipairs(out) do
		dir = dir:gsub("/$", "")
		local py = python_in(dir)
		if py then
			table.insert(items, {
				text = vim.fn.fnamemodify(dir, ":~:."), -- display relative to home/cwd
				python = py,
				dir = dir,
			})
		end
	end

	if #items == 0 then
		vim.notify("No virtualenvs found under " .. cwd, vim.log.levels.WARN, { title = "venv" })
		return
	end

	Snacks.picker.pick({
		source = "venvs",
		title = "Python Virtualenvs",
		items = items,
		format = "text",
		confirm = function(picker, item)
			picker:close()
			if item then
				M.apply(item.python)
			end
		end,
	})
end

return M
