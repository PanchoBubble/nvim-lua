vim.g.mapleader = " "
local env_file = vim.fn.expand "~/.config/nvim/.env"
if vim.fn.filereadable(env_file) == 1 then
  for line in io.lines(env_file) do
    local key, value = line:match "([^=]+)=(.+)"
    if key and value then
      vim.fn.setenv(key, value)
    end
  end
end

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end

-- Add lazy to the `runtimepath`, this allows us to `require` it.
---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Set up lazy, and load my `lua/custom/plugins/` folder
require("lazy").setup({ import = "config/plugins" }, {
  change_detection = {
    notify = false,
  },
})

require "config.autocmds"
require "config.keymaps"
require "config.options"
require "personal.git"
