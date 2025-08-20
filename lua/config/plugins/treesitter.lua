return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        branch = "master",
        lazy = false,
        config = function()
            require 'nvim-treesitter.configs'.setup({
                modules = {},
                autotag = { enable = true },
                sync_install = false, -- Async installation for better startup
                auto_install = false, -- Manual control over parser installation
                ignore_install = {},
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "gnn",
                        node_incremental = "grn",
                        scope_incremental = "grc",
                        node_decremental = "grm",
                    },
                },
                highlight = { 
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = { 
                    enable = true,
                    disable = { "yaml" }, -- YAML indentation can be problematic
                },
                ensure_installed = {
                    "bash",
                    "go",
                    "gomod",
                    "gosum",
                    "gowork",
                    "lua",
                    "html",
                    "javascript",
                    "tsx",
                    "json",
                    "markdown",
                    "markdown_inline",
                    "typescript",
                    "vim",
                    "yaml",
                    "dockerfile",
                    "sql",
                },
            })
        end
    },
}
