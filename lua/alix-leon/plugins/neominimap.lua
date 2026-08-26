return {
	"Isrothy/neominimap.nvim",
	version = "v3.*",
	lazy = false,
	init = function()
		vim.opt.wrap = false
		vim.opt.sidescrolloff = 36

		vim.g.neominimap = {
			auto_enable = true,
			winopt = function(opt, _)
				opt.winblend = 40
			end,
		}
	end,
}