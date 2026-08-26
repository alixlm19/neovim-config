return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- Python is deliberately absent: the ruff language server (see
		-- lsp/lspconfig.lua) already publishes ruff diagnostics, so listing
		-- ruff here too would surface every finding twice.
		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescript = { "eslint_d" },
			typescriptreact = { "eslint_d" },
		}

		-- Flat config (ESLint 9+) first, then the legacy .eslintrc family.
		local eslint_configs = {
			"eslint.config.js",
			"eslint.config.mjs",
			"eslint.config.cjs",
			"eslint.config.ts",
			"eslint.config.mts",
			"eslint.config.cts",
			".eslintrc.js",
			".eslintrc.cjs",
			".eslintrc.json",
			".eslintrc.yaml",
			".eslintrc.yml",
		}

		-- eslint_d exits non-zero and writes "Could not find config file" to
		-- stderr when a buffer lives outside an ESLint project, which nvim-lint
		-- surfaces as an error notification on every keystroke. Only lint once
		-- we've found a config by walking up from the file.
		local function has_eslint_config(bufnr)
			local name = vim.api.nvim_buf_get_name(bufnr)
			if name == "" then
				return false
			end
			local found = vim.fs.find(eslint_configs, {
				upward = true,
				type = "file",
				path = vim.fs.dirname(name),
			})
			return #found > 0
		end

		local function try_lint()
			local bufnr = vim.api.nvim_get_current_buf()
			local linters = lint.linters_by_ft[vim.bo[bufnr].filetype]
			if not linters then
				return
			end
			if vim.tbl_contains(linters, "eslint_d") and not has_eslint_config(bufnr) then
				return
			end
			lint.try_lint()
		end

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = try_lint,
		})

		vim.keymap.set("n", "<leader>l", try_lint, { desc = "Trigger linting for current file" })
	end,
}
