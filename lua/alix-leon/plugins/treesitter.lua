return {
	"nvim-treesitter/nvim-treesitter",
	-- The `main` branch is a full rewrite and is now upstream's default; the
	-- old `master` branch is frozen and explicitly does not support Neovim
	-- 0.12. None of the previous `nvim-treesitter.configs` setup applies here:
	-- there is no ensure_installed/highlight/indent table any more, and the
	-- plugin does not support lazy-loading.
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		local ts = require("nvim-treesitter")

		ts.setup({})

		-- Parser names, not filetypes: `tsx` backs the `typescriptreact`
		-- filetype, `typescript` backs `typescript`.
		local parsers = {
			"bash",
			"c",
			"css",
			"diff",
			"dockerfile",
			"gitcommit",
			"gitignore",
			"graphql",
			"html",
			"javascript",
			"json",
			"lua",
			"luadoc",
			"markdown",
			"markdown_inline",
			"prisma",
			"python",
			"query",
			"regex",
			"svelte",
			"toml",
			"tsx",
			"typescript",
			"vim",
			"vimdoc",
			"yaml",
		}

		-- install() is async and a no-op for parsers already present, but
		-- diffing first keeps startup from queueing 27 jobs on every launch.
		local installed = ts.get_installed("parsers")
		local missing = vim.tbl_filter(function(lang)
			return not vim.tbl_contains(installed, lang)
		end, parsers)
		if #missing > 0 then
			ts.install(missing)
		end

		-- Highlighting and indentation are no longer switched on by the plugin.
		-- Rather than hardcode a filetype list that drifts from the parser list
		-- above, enable them wherever a parser actually resolves.
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
			callback = function(ev)
				local lang = vim.treesitter.language.get_lang(ev.match)
				if not lang then
					return
				end
				local ok, added = pcall(vim.treesitter.language.add, lang)
				if not ok or added == false then
					return
				end
				pcall(vim.treesitter.start, ev.buf, lang)
				-- Upstream still marks treesitter indent experimental.
				vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})

		-- Must be called explicitly: nvim-ts-autotag's lazy auto-attach path
		-- still reaches for `nvim-treesitter.configs`, which no longer exists
		-- on the main branch, and would error on first attach.
		require("nvim-ts-autotag").setup({})
	end,
}
