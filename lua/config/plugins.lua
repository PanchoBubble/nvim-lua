return {
    -- random
    { 'eandrju/cellular-automaton.nvim' },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    -- change some telescope options and a keymap to browse plugin files
    { "nvim-lua/plenary.nvim" },
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.5',
        -- or                              , branch = '0.1.x',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },

    -- Session
    { 'rmagatti/auto-session' },
    -- NvimTree
    { "nvim-tree/nvim-tree.lua" },
    -- LSP Support
    { 'neovim/nvim-lspconfig' },

    -- Autocompletion
    { 'hrsh7th/nvim-cmp' }, { 'hrsh7th/cmp-buffer' }, { 'hrsh7th/cmp-path' },
    { 'saadparwaiz1/cmp_luasnip' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-nvim-lua' },

    -- Snippets
    { 'L3MON4D3/LuaSnip' },
    { 'rafamadriz/friendly-snippets' },
    -- React
    { "tasn/vim-tsx" },
    -- Git Blame
    { "f-person/git-blame.nvim" },
    -- Theme
    { 'nvim-tree/nvim-web-devicons' },
    { 'loctvl842/monokai-pro.nvim' },
    -- { 'nikolvs/vim-sunbather' },
    -- { 'rose-pine/neovim',               name = 'rose-pine' },

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
    { 'akinsho/bufferline.nvim' },
    { "folke/neodev.nvim",      opts = {} },
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
    },
    -- GIT
    { "tpope/vim-fugitive" },

    -- AUTO PAIRS
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        opts = {} -- this is equalent to setup({}) function
    },
    -- Copilot
    { 'github/copilot.vim' },
    -- Toggle comment
    -- -- add this to your lua/plugins.lua, lua/plugins/init.lua,  or the file you keep your other plugins:
    {
        'numToStr/Comment.nvim',
        opts = {},
        lazy = false,
    },
    -- Autotags close
    { 'windwp/nvim-ts-autotag' },
    -- Replace
    { 'nvim-pack/nvim-spectre' }
}
