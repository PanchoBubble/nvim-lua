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

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50



-- Give more space for displaying messages.
vim.opt.cmdheight = 2

-- Having longer update time (default is 4000 ms = 4 s) leads to noticeable
-- delays and poor user experience.
vim.opt.updatetime = 50

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1 -- set termguicolors to enable highlight groups


vim.opt.termguicolors = true -- empty setup using defaults

vim.opt.hidden = true
vim.opt.updatetime = 300

vim.opt.shortmess = vim.opt.shortmess + 'c'

-- always show signcolumns
vim.opt.signcolumn = 'yes'
vim.opt.spell = true


vim.opt.mouse = 'nicr'
vim.opt.mouse = 'a'
-- vim.cmd('colorscheme rose-pine-main')
-- vim.cmd('colorscheme sunbather')
vim.cmd('colorscheme monokai-pro-spectrum')
-- vim.opt.colorcolumn = "120"
-- vim.cmd('highlight ColorColumn ctermbg=0 guibg=salmon')

vim.g.blamer_enabled = true

vim.g.copilot_no_tab_map = true
vim.g.copilot_filetypes = {
    ["*"] = false,
    ["javascript"] = true,
    ["typescript"] = true,
    ["lua"] = false,
    ["rust"] = true,
    ["c"] = true,
    ["c#"] = true,
    ["c++"] = true,
    ["go"] = true,
    ["python"] = true,
}

vim.o.sessionoptions = "buffers,curdir,tabpages,terminal,localoptions"
