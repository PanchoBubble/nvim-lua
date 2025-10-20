return {
  -- React
  { "tasn/vim-tsx" },

  -- Git Blame
  {
    "f-person/git-blame.nvim",
    -- lazy = true,
    -- cmd = { "GitBlameToggle", "GitBlameEnable" },
    -- config = function()
    --     vim.g.gitblame_enabled = 0  -- Disabled by default, enable when needed
    -- end
  },

  -- TMUX
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
  -- Theme
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    event = "VeryLazy",
  },
  {
    "loctvl842/monokai-pro.nvim",
    lazy = true,
    priority = 1000,
    config = function()
      require("monokai-pro").setup {
        transparent_background = false,
        terminal_colors = true,
        devicons = true,
        styles = {
          comment = { italic = true },
          keyword = { italic = false }, -- reducing italics improves performance
          functions = { italic = false },
          strings = { italic = false },
          variables = { italic = false },
        },
        filter = "pro", -- classic | octagon | pro | machine | ristretto | spectrum
        background_clear = {}, -- disable background for specific filetypes
        day_night = {
          enable = false, -- disabling this feature improves performance
        },
      }
    end,
  },

  -- GIT
  {
    "tpope/vim-fugitive",
    lazy = false,
    cmd = {
      "Git",
      "Gwrite",
      "Gcommit",
      "Gpush",
      "Gpull",
    },
  },

  -- Uncommited changes
  {
    "mhinz/vim-signify",
    lazy = true,
    event = "BufReadPre",
    config = function()
      -- Update less frequently
      vim.g.signify_realtime = 0
      vim.g.signify_updatetime = 500
    end,
  },

  -- Mustache
  {
    "mustache/vim-mustache-handlebars",
    ft = { "mustache", "handlebars" }, -- Load only for specific filetypes
  },
}
