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
                sync_install = true,
                auto_install = true,
                ignore_install = {},
                highlight = { enable = true },
                indent = { enable = true },
                ensure_installed = {
                    "bash",
                    "go",
                    "lua",
                    "html",
                    "javascript",
                    "json",
                    "graphql",
                    "markdown",
                    "markdown_inline",
                    "python",
                    "query",
                    "regex",
                    "typescript",
                    "vim",
                    "yaml",
                },
            })
        end

    },
}
