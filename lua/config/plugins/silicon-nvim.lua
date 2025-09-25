return {
  {
    "michaelrommel/nvim-silicon",
    lazy = true,
    cmd = "Silicon",
    init = function()
      local function silicon_opts()
        local bg_color = vim.api.nvim_get_hl(0, { name = 'Normal' }).bg
        local bg_hex = bg_color and string.format("#%06x", bg_color) or '#1e1e1e'
        
        return {
          font = "JetBrains Mono=34;Noto Color Emoji=34",
          background = bg_hex,
          shadow_color = "#555555",
          line_pad = 2,
          line_offset = 1,
          pad_horiz = 80,
          pad_vert = 100,
          shadow_blur_radius = 20,
          shadow_offset_x = 8,
          shadow_offset_y = 8,
          line_number = true,
          round_corner = true,
          window_controls = true,
          window_title = function()
            return vim.fn.fnamemodify(
              vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()),
              ":t"
            )
          end,
          to_clipboard = false,
          output = function()
            local config_dir = vim.fn.expand("~/.config/nvim")
            local preview_dir = config_dir .. "/images/syntax-previews/"
            vim.fn.mkdir(preview_dir, "p")
            
            local filetype = vim.bo.filetype
            local timestamp = os.date("%Y%m%d_%H%M%S")
            return preview_dir .. "silicon_" .. filetype .. "_" .. timestamp .. ".png"
          end,
        }
      end
      
      vim.g.silicon = silicon_opts()
    end,
    config = function()
      -- Auto-update silicon config when colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          local bg_color = vim.api.nvim_get_hl(0, { name = 'Normal' }).bg
          local bg_hex = bg_color and string.format("#%06x", bg_color) or '#1e1e1e'
          
          if vim.g.silicon and vim.g.silicon.background then
            vim.g.silicon.background = bg_hex
          end
        end,
        desc = "Update Silicon background color on colorscheme change"
      })
    end,
  },
}
