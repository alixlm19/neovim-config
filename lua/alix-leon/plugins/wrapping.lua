return {
	"andrewferrier/wrapping.nvim",
	config = function()
		local opts = {
			auto_set_mode_filetype_allowlist = {
				"asciidoc",
				"gitcommit",
				"latex",
				"mail",
				"markdown",
				"rst",
				"tex",
				"text",
			},
		}
		require("wrapping").setup(opts)
	end,
}
