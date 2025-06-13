return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		local toggleterm = require("toggleterm")
		local keymap = vim.keymap

		keymap.set(
			"n",
			"<leader>tt",
			"<cmd>ToggleTerm size=10 direction=horizontal<CR>",
			{ desc = "Open the terminal" }
		)
		function _G.set_terminal_keymaps()
			local opts = { buffer = 0 }
			keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
			keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
			keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
			keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
			keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
			keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
		end

		vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
		toggleterm.setup()
	end,
}
