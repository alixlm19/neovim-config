return {
<<<<<<< HEAD
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = true -- runs require('Comment').setup()
=======
	"numToStr/Comment.nvim",
	event = { "BufReadPre", "BufNewfile", },
	dependencies = {
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	config = function()
		-- Import comment plugin safely
		local comment = require("Comment") 

		local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")

		-- Enable comment
		comment.setup({
			-- For commenting tsx, jsx, html files, etc.
			pre_hook = ts_context_commentstring.create_pre_hook(),
		})
	end,
>>>>>>> windows
}
