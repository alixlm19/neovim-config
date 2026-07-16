return {
	"folke/lazydev.nvim",
	ft = "lua", -- only load on lua files
	opts = {
		library = {
			-- Load luvit types when the `vim.uv` word is found.
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			-- Load snacks types (e.g. `snacks.Config`) when `Snacks` is referenced.
			{ path = "snacks.nvim", words = { "Snacks" } },
		},
	},
}