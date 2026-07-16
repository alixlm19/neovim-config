return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  config = function()
    require("smart-splits").setup({
      multiplexer_integration = "tmux",
      resize_mode = {
        quit_key = "<ESC>",
        resize_keys = { "h", "j", "k", "l" },
        silent = true,
      },
      ignored_filetypes = { "nofile", "quickfix", "prompt" },
      ignored_buftypes = { "nofile" },
    })

    -- keymaps set after setup
    local s = require("smart-splits")
    vim.keymap.set({ "n", "t" }, "<C-h>", s.move_cursor_left,  { desc = "Move Left" })
    vim.keymap.set({ "n", "t" }, "<C-j>", s.move_cursor_down,  { desc = "Move Down" })
    vim.keymap.set({ "n", "t" }, "<C-k>", s.move_cursor_up,    { desc = "Move Up" })
    vim.keymap.set({ "n", "t" }, "<C-l>", s.move_cursor_right, { desc = "Move Right" })
    vim.keymap.set("n", "<A-h>", s.resize_left,       { desc = "Resize Left" })
    vim.keymap.set("n", "<A-j>", s.resize_down,       { desc = "Resize Down" })
    vim.keymap.set("n", "<A-k>", s.resize_up,         { desc = "Resize Up" })
    vim.keymap.set("n", "<A-l>", s.resize_right,      { desc = "Resize Right" })
  end,
}
