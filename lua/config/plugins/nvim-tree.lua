return {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
        'akinsho/bufferline.nvim',
    },
    config = function()
        require("nvim-tree").setup({
            git = {
                enable = true,
                ignore = false,
                timeout = 500,
            },
            view = { adaptive_size = true },
            update_cwd = true,
            filters = {
                dotfiles = false,
                custom = { 'node_modules' }
            },
            update_focused_file = {
                enable = true,
                update_cwd = true,
            },
            filesystem_watchers = {
                enable = true,
                debounce_delay = 50,
                ignore_dirs = { "node_modules" },
            },
        })
        require("bufferline").setup({
            options = {
                offsets = {
                    {
                        filetype = "NvimTree",
                        text = "Nvim Tree",
                        separator = true,
                        text_align = "left"
                    }
                },
            }
        })
    end
}
