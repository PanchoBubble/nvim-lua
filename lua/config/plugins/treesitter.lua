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
                highlight = { enable = true },
                indent = { enable = true },
                ensure_installed = {
                    -- "bash",
                    -- "go",
                    "lua",
                    "html",
                    "javascript",
                    "tsx",
                    "json",
                    -- "graphql",
                    "markdown",
                    -- "markdown_inline",
                    -- "python",
                    -- "query",
                    -- "regex",
                    "typescript",
                    -- "vim",
                    "yaml",
                },
            })
        end

    },
}
