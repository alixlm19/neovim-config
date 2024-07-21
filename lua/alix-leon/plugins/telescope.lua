return {
    'nvim-telescope/telescope.nvim',
    cmd = "Telescope",
    version = false,
    tag = '0.1.5',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
        extensions = {

            fzf = {
                fuzzy = true,
                override_generic_sorter = true,
                override_file_sorter = true,
                case_mode = "smart_case"
            }
        }
    }
}
