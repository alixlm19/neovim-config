return {
	"mrjones2014/smart-splits.nvim",
	lazy = false, -- Load at startup so mappings work immediately
	keys = {
		-- 1. Navigation (Ctrl + h/j/k/l)
		-- These move cursor inside Neovim. If at the edge, they move to the Zellij pane.
		{
			"<C-h>",
			function()
				require("smart-splits").move_cursor_left()
			end,
			desc = "Move Left",
		},
		{
			"<C-j>",
			function()
				require("smart-splits").move_cursor_down()
			end,
			desc = "Move Down",
		},
		{
			"<C-k>",
			function()
				require("smart-splits").move_cursor_up()
			end,
			desc = "Move Up",
		},
		{
			"<C-l>",
			function()
				require("smart-splits").move_cursor_right()
			end,
			desc = "Move Right",
		},

		-- 2. Resizing (Alt + h/j/k/l)
		-- Optional: these resize Neovim splits.
		{
			"<A-h>",
			function()
				require("smart-splits").resize_left()
			end,
			desc = "Resize Left",
		},
		{
			"<A-j>",
			function()
				require("smart-splits").resize_down()
			end,
			desc = "Resize Down",
		},
		{
			"<A-k>",
			function()
				require("smart-splits").resize_up()
			end,
			desc = "Resize Up",
		},
		{
			"<A-l>",
			function()
				require("smart-splits").resize_right()
			end,
			desc = "Resize Right",
		},
	},
	config = function()
		require("smart-splits").setup({
			-- If you have a specific column width you like for resizing
			resize_mode = {
				quit_key = "<ESC>",
				resize_keys = { "h", "j", "k", "l" },
				silent = true,
				hooks = {
					on_enter = nil,
					on_leave = nil,
				},
			},
			-- Disable default mappings if you defined them in 'keys' above
			ignored_filetypes = {
				"nofile",
				"quickfix",
				"prompt",
			},
			ignored_buftypes = { "nofile" },
		})
	end,
}
