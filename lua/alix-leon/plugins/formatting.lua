return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			-- Python is deliberately absent: lsp/lspconfig.lua installs a
			-- BufWritePre autocmd that organizes imports and formats via the
			-- ruff language server. Listing ruff here too would format twice.
			formatters_by_ft = {
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				lua = { "stylua" },
				toml = { "taplo" },
			},
			format_on_save = function(bufnr)
				-- See the note above: ruff already owns Python on save, and an
				-- lsp fallback here would re-run it a second time.
				if vim.bo[bufnr].filetype == "python" then
					return nil
				end
				return { lsp_format = "fallback", timeout_ms = 1000 }
			end,
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({ lsp_format = "fallback", async = false, timeout_ms = 1000 })
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
