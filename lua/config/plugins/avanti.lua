return {
    "yetone/avante.nvim",
    event = { "BufReadPost", "BufNewFile" }, -- Load when buffer is read or created
    lazy = true,
    version = "*",                           -- Always use latest stable release
    opts = {
        provider = "claude",
        cursor_applying_provider = "claude", -- Explicitly set for consistency
        auto_suggestions_provider = nil,     -- Disabled by default for performance
        suggestion = {
            debounce = 500,                  -- Delay before triggering suggestions (ms)
            enabled = true,
            max_lines = 500,                 -- Max lines to analyze for suggestions
        },
        claude = {
            endpoint = "https://api.anthropic.com",
            model = "claude-3-5-sonnet-20241022",
            temperature = 0.1, -- Slightly increased for more creative responses
            max_tokens = 4096,
            top_p = 0.95,      -- Add top_p for better response quality
            timeout = 60,      -- Add timeout in seconds
        },
        ui = {
            code_action_icon = "💡",
            border = "rounded",
            width = 0.8,           -- 80% of screen width
            height = 0.8,          -- 80% of screen height
        },
        file_picker = "telescope", -- Use telescope as default file picker
    },
    build = "make",
    dependencies = {
        -- Required dependencies
        "nvim-treesitter/nvim-treesitter",
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
        {
            "nvim-telescope/telescope.nvim",
            lazy = true,
            cmd = "Telescope",
        },
        {
            "hrsh7th/nvim-cmp",
            event = "InsertEnter",
        },
        {
            -- support for image pasting
            "HakonHarnes/img-clip.nvim",
            event = "VeryLazy",
            opts = {
                -- recommended settings
                default = {
                    embed_image_as_base64 = false,
                    prompt_for_file_name = false,
                    drag_and_drop = {
                        insert_mode = true,
                    },
                    -- required for Windows users
                    use_absolute_path = true,
                },
            },
        },
        {
            -- Make sure to set this up properly if you have lazy=true
            'MeanderingProgrammer/render-markdown.nvim',
            opts = {
                file_types = { "markdown", "Avante" },
            },
            ft = { "markdown", "Avante" },
        },
    },
}
