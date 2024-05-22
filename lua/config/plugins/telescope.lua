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
        }
    end,
}
