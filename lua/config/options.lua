vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

-- Give more space for displaying messages.
vim.opt. cmdheight=2

-- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
-- delays and poor user experience.
vim.opt.updatetime=50

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1-- set termguicolors to enable highlight groups


vim.opt.termguicolors = true-- empty setup using defaults

require("nvim-tree").setup({
    view = { adaptive_size = true }
})

require('nvim-treesitter.configs').setup {
  highlight = {
    enabled = true
  }
}

vim.opt.hidden = true
vim.opt.updatetime = 300

vim.opt.shortmess = vim.opt.shortmess + 'c'

-- always show signcolumns
vim.opt.signcolumn = 'yes'


vim.opt.mouse = 'nicr'
vim.opt.mouse = 'a'
vim.cmd('colorscheme rose-pine')
vim.g.blamer_enabled = true

vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
