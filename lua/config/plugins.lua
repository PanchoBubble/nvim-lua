return {
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    -- change some telescope options and a keymap to browse plugin files
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope.nvim" },

    -- Session
    { 'rmagatti/auto-session' },
    -- NvimTree
    { "nvim-tree/nvim-tree.lua" },
    -- LSP Support
    { 'neovim/nvim-lspconfig' },

    -- Autocompletion
    { 'hrsh7th/nvim-cmp' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-path' },
    { 'saadparwaiz1/cmp_luasnip' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-nvim-lua' },

    -- Snippets
    { 'L3MON4D3/LuaSnip' },
    { 'rafamadriz/friendly-snippets' },
    -- React
    { "tasn/vim-tsx" },
    -- Git Blame
    { "apzelos/blamer.nvim" },
    -- Theme
    { 'nvim-tree/nvim-web-devicons' },
    { 'rose-pine/neovim',                 name = 'rose-pine' },

    -- add tsserver and setup with typescript.nvim instead of lspconfig
    { "neovim/nvim-lspconfig" },

    -- add more treesitter parsers
    { "nvim-treesitter/nvim-treesitter" },

    -- Noice
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {
            -- add any options here
        },
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify",
        }
    },

    -- Rainbow brackets
    { "HiPhish/nvim-ts-rainbow2" },
}
