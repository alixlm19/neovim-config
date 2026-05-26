return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "saghen/blink.cmp" },
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local lspconfig = require("lspconfig")
		local mason_lspconfig = require("mason-lspconfig")
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

		mason_lspconfig.setup({
			function(server_name)
				lspconfig[server_name].setup({
					capabilities = capabilities,
				})
			end,
			["lua_ls"] = function()
				lspconfig["lua_ls"].setup({
					capabilities = capabilities,
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
			end,
			["pyright"] = function()
				local venv = os.getenv("VIRTUAL_ENV")
				local python_path = venv and (venv .. "/bin/python")
					or (vim.fn.getcwd() .. "/.venv/bin/python")

				if vim.fn.filereadable(python_path) == 0 then
					python_path = vim.fn.exepath("python3")
				end

				lspconfig["pyright"].setup({
					capabilities = capabilities,
					settings = {
						python = {
							pythonPath = python_path,
							analysis = {
								autoSearchPaths = true,
								useLibraryCodeForTypes = true,
								diagnosticMode = "openFilesOnly",
							},
						},
					},
				})
			end,
		})
	end,
}
