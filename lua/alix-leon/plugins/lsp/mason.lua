return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		local mason = require("mason")

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")

		local mason_tool_installer = require("mason-tool-installer")

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			-- List of servers for mason to install
			-- mason-lspconfig v2 auto-enables every server installed in Mason,
			-- so anything missing here still ran on machines that happened to
			-- have it installed by hand. Declaring them keeps a fresh clone
			-- identical to an existing one.
			ensure_installed = {
				-- Python
				"pyright",
				"ruff",
				-- Lua
				"lua_ls",
				-- Prose/grammar
				"harper_ls",
				-- Web / TypeScript
				"ts_ls",
				"html",
				"cssls",
				"tailwindcss",
				"emmet_ls",
				"prismals",
			},
			-- nvim-lspconfig ships a `stylua --lsp` server definition, so
			-- automatic_enable started stylua as a language server purely
			-- because it is installed as a CLI formatter. conform runs the
			-- binary directly, so the server was a redundant process.
			-- (taplo is left enabled — its server adds real TOML validation.)
			automatic_enable = {
				exclude = { "stylua", "stylua3p_ls" },
			},
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"prettier", -- conform: js/ts/html/css/json/yaml/markdown
				"stylua", -- conform: lua
				"taplo", -- conform: toml
				"ruff", -- lsp: python format + diagnostics
				"eslint_d", -- nvim-lint: js/ts/jsx/tsx
			},
		})
	end,
}
