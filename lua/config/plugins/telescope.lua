return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        { "nvim-telescope/telescope-fzf-native.nvim",   build = "make" },
        { "nvim-telescope/telescope-smart-history.nvim" },
        { "kkharji/sqlite.lua" },
    },
    config = function()
        require("telescope").setup {
            extensions = {
                fzf = {},
                wrap_results = true,
                history = {
                    limit = 100,
                },
            },
            vimgrep_arguments = {
                'rg',
                '--color=never',
                '--no-heading',
                '--with-filename',
                '--line-number',
                '--column',
                '--smart-case',
                '--hidden',
                '--max-columns=150',
                '--max-filesize=1M',
            },
            defaults = {
                file_ignore_patterns = {
                    "node_modules/",
                    ".git/",
                    "target/",
                    "dist/",
                    "build/"
                },
                cache_picker = {
                    num_pickers = 5,
                    limit_entries = 1000,
                },
            },
        }
    end,
}
