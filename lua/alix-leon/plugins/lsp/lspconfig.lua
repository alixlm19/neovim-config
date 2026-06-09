return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "saghen/blink.cmp" },
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local keymap = vim.keymap

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }

				opts.desc = "Show LSP references"
				keymap.set("n", "gR", function() Snacks.picker.lsp_references() end, opts)

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", function() Snacks.picker.lsp_definitions() end, opts)

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", function() Snacks.picker.lsp_implementations() end, opts)

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", function() Snacks.picker.lsp_type_definitions() end, opts)

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", function() Snacks.picker.diagnostics_buffer() end, opts)

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts)

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", function()
					for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
						client:stop()
					end
					vim.defer_fn(function() vim.cmd("edit") end, 500)
				end, opts)

				-- On save, organize imports then format with ruff. Both are scoped
				-- to the ruff client so pyright (no formatter) is never asked.
				-- We use source.organizeImports (isort) which sorts/groups imports
				-- but does NOT remove unused ones — that's source.fixAll (F401),
				-- which we deliberately omit.
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				if client and client.name == "ruff" then
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = vim.api.nvim_create_augroup("RuffFormat", { clear = false }),
						buffer = ev.buf,
						callback = function()
							-- Organize imports synchronously so the edits land before
							-- we format. code_action() is async, so we drive the request
							-- ourselves and apply the resulting workspace edit inline.
							local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
							params.context = { only = { "source.organizeImports.ruff" }, diagnostics = {} }
							local result = client:request_sync("textDocument/codeAction", params, 1000, ev.buf)
							for _, action in ipairs((result or {}).result or {}) do
								if action.edit then
									vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
								end
							end

							vim.lsp.buf.format({
								bufnr = ev.buf,
								filter = function(c) return c.name == "ruff" end,
							})
						end,
					})
				end
			end,
		})

		local capabilities = require("blink.cmp").get_lsp_capabilities()
		capabilities.positionEncodings = { "utf-16" }

		-- suppress noisy unknown filetype warnings from tailwindcss/emmet
		vim.lsp.log.set_level(vim.log.levels.ERROR)

		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.diagnostic.config({
				signs = {
					text = icon,
					texthl = hl,
					numhl = "",
				},
			})
		end

		-- mason-lspconfig v2 dropped setup_handlers; on Neovim 0.11+ servers are
		-- configured with vim.lsp.config() and enabled by v2's automatic_enable.
		local venv = require("alix-leon.core.venv")

		-- Applied to every server.
		vim.lsp.config("*", { capabilities = capabilities })

		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim", "Snacks" },
					},
					completion = {
						callSnippet = "Replace",
					},
				},
			},
		})

		vim.lsp.config("pyright", {
			-- Resolved per project root, so each Python project gets its own
			-- venv automatically (walks up for monorepo layouts). root_dir is
			-- populated on the config by the time before_init runs.
			before_init = function(_, config)
				config.settings = config.settings or {}
				config.settings.python = config.settings.python or {}
				config.settings.python.pythonPath = venv.detect(config.root_dir)
			end,
			settings = {
				python = {
					analysis = {
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
						diagnosticMode = "openFilesOnly",
					},
				},
			},
		})

		vim.lsp.config("ruff", {
			-- Match pyright's interpreter so import resolution agrees.
			before_init = function(_, config)
				config.init_options = config.init_options or {}
				config.init_options.settings = config.init_options.settings or {}
				config.init_options.settings.interpreter = { venv.detect(config.root_dir) }
			end,
		})

		-- Manual override: fuzzy-pick any venv under the cwd.
		keymap.set("n", "<leader>cv", venv.pick, { desc = "Select Python venv" })
	end,
}
