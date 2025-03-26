return {
    {
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
    },
    {
        "antosha417/nvim-lsp-file-operations",
        dependencies = {
            "nvim-lua/plenary.nvim",
            -- Uncomment whichever supported plugin(s) you use
            "nvim-tree/nvim-tree.lua",
            -- "nvim-neo-tree/neo-tree.nvim",
            -- "simonmclean/triptych.nvim"
        },
        config = function()
            require("lsp-file-operations").setup()
        end,
    },

}
