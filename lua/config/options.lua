vim.opt.guicursor = ""

vim.wo.number = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv "HOME" .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append "@-@"

-- Give more space for displaying messages.
vim.opt.cmdheight = 2

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1 -- set termguicolors to enable highlight groups

vim.opt.termguicolors = true -- empty setup using defaults

vim.opt.shortmess = vim.opt.shortmess + "c"

-- always show signcolumns
vim.opt.signcolumn = "yes"
vim.opt.spell = true

vim.opt.mouse = "nicr"
vim.opt.mouse = "a"
vim.cmd "colorscheme monokai-pro"

vim.g.blamer_enabled = true

vim.o.sessionoptions = "buffers,curdir,folds,tabpages,winsize,localoptions"

-- Performance related settings
vim.opt.hidden = true
vim.opt.history = 100
vim.opt.lazyredraw = true
vim.opt.synmaxcol = 240
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400
vim.opt.redrawtime = 1500
vim.opt.ttimeoutlen = 10

local disabled_built_ins = {
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logipat",
  "spellfile_plugin",
  "matchit",
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end

-- Use faster grep if available
if vim.fn.executable "rg" == 1 then
  vim.o.grepprg = "rg --vimgrep --no-heading --smart-case"
  vim.o.grepformat = "%f:%l:%c:%m"
end

-- LSP performance improvements
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  -- Avoid redundant redraw
  focusable = false,
  border = "rounded",
})

-- Debounce LSP document highlights
local function debounce(ms, fn)
  local timer = vim.loop.new_timer()
  return function(...)
    local argv = { ... }
    timer:start(ms, 0, function()
      timer:stop()
      vim.schedule_wrap(fn)(unpack(argv))
    end)
  end
end

vim.lsp.handlers["textDocument/documentHighlight"] = debounce(150, vim.lsp.handlers["textDocument/documentHighlight"])
