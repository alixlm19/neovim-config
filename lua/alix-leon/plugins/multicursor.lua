return {
	"jake-stewart/multicursor.nvim",
	branch = "1.0",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local mc = require("multicursor-nvim")

		mc.setup()

		local keymap = vim.keymap

		-- add or skip cursor above/below the main cursor
		keymap.set({ "n", "x" }, "<up>", function() mc.lineAddCursor(-1) end, { desc = "Add cursor above" })
		keymap.set({ "n", "x" }, "<down>", function() mc.lineAddCursor(1) end, { desc = "Add cursor below" })
		keymap.set({ "n", "x" }, "<leader>mk", function() mc.lineSkipCursor(-1) end, { desc = "Skip cursor above" })
		keymap.set({ "n", "x" }, "<leader>mj", function() mc.lineSkipCursor(1) end, { desc = "Skip cursor below" })

		-- add or skip a cursor by matching word/selection
		keymap.set({ "n", "x" }, "<C-n>", function() mc.matchAddCursor(1) end, { desc = "Add cursor at next match" })
		keymap.set({ "n", "x" }, "<leader>mn", function() mc.matchAddCursor(1) end, { desc = "Add cursor at next match" })
		keymap.set({ "n", "x" }, "<leader>mN", function() mc.matchAddCursor(-1) end, { desc = "Add cursor at previous match" })
		keymap.set({ "n", "x" }, "<leader>mq", function() mc.matchSkipCursor(1) end, { desc = "Skip next match" })
		keymap.set({ "n", "x" }, "<leader>mQ", function() mc.matchSkipCursor(-1) end, { desc = "Skip previous match" })
		keymap.set({ "n", "x" }, "<leader>mA", mc.matchAllAddCursors, { desc = "Add cursors at all matches" })

		-- visual mode helpers
		keymap.set("x", "<leader>mM", mc.matchCursors, { desc = "Add cursors at regex matches in selection" })
		keymap.set("x", "<leader>mS", mc.splitCursors, { desc = "Split selection into cursors by regex" })
		keymap.set("x", "I", mc.insertVisual, { desc = "Insert on each line of selection" })
		keymap.set("x", "A", mc.appendVisual, { desc = "Append on each line of selection" })

		-- toggle / restore cursors
		keymap.set({ "n", "x" }, "<leader>mt", mc.toggleCursor, { desc = "Toggle cursor" })
		keymap.set("n", "<leader>mr", mc.restoreCursors, { desc = "Restore cleared cursors" })
		keymap.set("n", "<leader>ma", mc.alignCursors, { desc = "Align cursor columns" })

		-- add and remove cursors with control + left click
		keymap.set("n", "<c-leftmouse>", mc.handleMouse)
		keymap.set("n", "<c-leftdrag>", mc.handleMouseDrag)
		keymap.set("n", "<c-leftrelease>", mc.handleMouseRelease)

		-- mappings only active while multiple cursors exist
		mc.addKeymapLayer(function(layerSet)
			layerSet({ "n", "x" }, "<left>", mc.prevCursor)
			layerSet({ "n", "x" }, "<right>", mc.nextCursor)
			layerSet({ "n", "x" }, "<leader>mx", mc.deleteCursor)

			layerSet("n", "<esc>", function()
				if not mc.cursorsEnabled() then
					mc.enableCursors()
				else
					mc.clearCursors()
				end
			end)
		end)
	end,
}
