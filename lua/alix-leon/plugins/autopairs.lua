return {
	"windwp/nvim-autopairs",
	event = { "InsertEnter" },
	dependencies = {
		"hrsh7th/nvim-cmp",
	},
	config = function()
		-- import nvim-autopairs
		local autopairs = require("nvim-autopairs")

		-- configure autopairs
		autopairs.setup({
			check_ts = true,						-- Enable treesitter
			ts_config = {
				lua = { "string" }, 				-- Don't add pairs in lua string treesitter nodes
				javascript = { "template_string" }, -- Don't add pairs in JavaScript template_string treesitter nodes
				java = false, 						-- Don't check treesitter on Java
			},
		})
		
		-- import nvim-autopairs completion functionality
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")

		-- import nvim-cmp plugin (completions plugin)
		local cmp = require("cmp")

		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
	end,
}
