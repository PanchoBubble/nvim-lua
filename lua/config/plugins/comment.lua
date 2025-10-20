return {
  {
    "numToStr/Comment.nvim",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      require("Comment").setup {
        -- Enable treesitter integration for context-aware commenting
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),

        -- Keymaps (defaults shown for reference)
        toggler = {
          line = "gcc", -- Line-comment toggle
          block = "gbc", -- Block-comment toggle
        },
        opleader = {
          line = "gc", -- Line-comment operator
          block = "gb", -- Block-comment operator
        },
        extra = {
          above = "gcO", -- Comment above
          below = "gco", -- Comment below
          eol = "gcA", -- Comment end of line
        },

        mappings = {
          basic = true,
          extra = true,
        },

        sticky = true, -- Keep cursor position
        ignore = "^$", -- Ignore empty lines
      }
    end,
    lazy = false,
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    opts = {
      enable_autocmd = false, -- Disable since using Comment.nvim integration
    },
  },
}
