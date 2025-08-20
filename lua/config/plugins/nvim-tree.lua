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
                view = { 
                    adaptive_size = true,
                    width = 35,
                },
                update_cwd = true,
                renderer = {
                    group_empty = true,
                    highlight_git = true,
                    icons = {
                        glyphs = {
                            folder = {
                                arrow_closed = "",
                                arrow_open = "",
                            },
                        },
                    },
                },
                filters = {
                    dotfiles = false,
                    custom = { 'node_modules', '.DS_Store', 'vendor' },
                },
                update_focused_file = {
                    enable = true,
                    update_cwd = true,
                },
                filesystem_watchers = {
                    enable = true,
                    debounce_delay = 50,
                    ignore_dirs = { "node_modules", '.DS_Store', 'vendor', '.git' },
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
