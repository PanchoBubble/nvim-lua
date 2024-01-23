vim.api.nvim_create_user_command("Cppath", function()
    local path = vim.fn.expand("%")
    vim.fn.setreg("+", path)
    vim.notify('Copied "' .. path .. '" to the clipboard!')
end, {})

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")


-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set("x", "<leader>d", [["_d]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader>n", "<cmd>NvimTreeToggle<CR>")

vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>")
vim.keymap.set("n", "<leader>fw", function()
    return "<cmd>Telescope live_grep default_text=" .. vim.fn.expand("<cword>") .. "<CR>"
end, { expr = true })

vim.keymap.set("n", "<C-p>", "<cmd>Telescope find_files<CR>")
vim.keymap.set("n", "<C-f>", "<cmd>Telescope live_grep<CR>")
vim.keymap.set("n", "<CS-C>", "<cmd>Cppath<CR>")

vim.keymap.set("n", "<leader>vpp", "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/theprimeagen/packer.lua<CR>")
vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>")

vim.keymap.set("n", "<leader>gd", "<cmd>Gdiff<CR>")

-- Buffer navigation
vim.keymap.set("n", "<C-J>", "<C-W><C-J>")
vim.keymap.set("n", "<C-K>", "<C-W><C-K>")
vim.keymap.set("n", "<C-H>", "<C-W><C-H>")
vim.keymap.set("n", "<C-L>", "<C-W><C-L>")

-- """""""" GO TO PREV FILE """"""""""""""
vim.keymap.set("n", "<leader>bb", "<C-^><cr>")

-- " move selected lines up one line
vim.keymap.set("x", "<S-UP>", ":m-2<CR>gv=gv")

-- " move selected lines down one line
vim.keymap.set("x", "<S-DOWN>", ":m'>+<CR>gv=gv")

-- Tabs and buffer
vim.keymap.set("n", "gt", "<cmd>tabnext<CR>")
vim.keymap.set("n", "gT", "<cmd>tabprevious<CR>")

vim.keymap.set('n', '<leader>qf', "<cmd>lua vim.lsp.buf.code_action()<CR>")
vim.keymap.set('n', '<leader><leader>', vim.lsp.buf.format)


vim.keymap.set('n', 'gr', function() require('telescope.builtin').lsp_references() end, { noremap = true, silent = true })
vim.keymap.set('n', 'gb', "<cmd>bnext<cr>")
vim.keymap.set('n', 'gB', "<cmd>bprev<cr>")
vim.keymap.set('n', '<C-q>', "<cmd>bd<cr><cmd>bnext<cr>")
vim.keymap.set('n', '<leader>Q', "<cmd>%bd|e#<cr>")



--- Trouble
local trouble = require("trouble")
local function troubleMaker(action)
    trouble.toggle(action)
end

vim.keymap.set("n", "<leader>xx", function() troubleMaker() end)
vim.keymap.set("n", "<leader>xw", function() troubleMaker("workspace_diagnostics") end)
vim.keymap.set("n", "<leader>xd", function() troubleMaker("document_diagnostics") end)
vim.keymap.set("n", "<leader>xq", function() troubleMaker("quickfix") end)
vim.keymap.set("n", "<leader>xl", function() troubleMaker("loclist") end)
vim.keymap.set("n", "gR", function() troubleMaker("lsp_references") end)
