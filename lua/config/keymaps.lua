vim.api.nvim_create_user_command("Cppath", function()
    local path = vim.fn.expand("%")
    vim.fn.setreg("+", path)
    vim.notify('Copied "' .. path .. '" to the clipboard!')
end, {})

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")


-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set("x", "<leader>d", [["_d]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
----------------------------------------------

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

local nvimTreeToggle = "<cmd>NvimTreeToggle<CR>"
vim.keymap.set("n", "<leader>n", nvimTreeToggle)

vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>")

vim.keymap.set("n", "<C-p>", "<cmd>Telescope find_files<CR>")

vim.keymap.set("n", "<leader>fw", function()
    return "<cmd>Telescope live_grep default_text=" .. vim.fn.expand("<cword>") .. "<CR>"
end, { expr = true })

vim.keymap.set("n", "<C-f>", "<cmd>Telescope live_grep <cr>")
vim.keymap.set("n", "<C-C>", "<cmd>Cppath<CR>")

vim.keymap.set("n", "<leader>vpp", "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/theprimeagen/packer.lua<CR>")
vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>")

vim.keymap.set("n", "<leader>gd", "<cmd>Gdiff<CR>")
vim.keymap.set("n", "gd", vim.lsp.buf.implementation)

-- Buffer navigation
vim.keymap.set("n", "<C-J>", "<C-W><C-J>")
vim.keymap.set("n", "<C-K>", "<C-W><C-K>")
vim.keymap.set("n", "<C-H>", "<C-W><C-H>")
vim.keymap.set("n", "<C-L>", "<C-W><C-L>")

-- """""""" GO TO PREV FILE """"""""""""""
vim.keymap.set("n", "<leader>bb", "<C-^><cr>")

-- Tabs and buffer
vim.keymap.set('n', '<leader>qf', "<cmd>lua vim.lsp.buf.code_action()<CR>")
local function prettify()
    if vim.fn.exists(':EslintFixAll') > 0 then
        vim.cmd("EslintFixAll")
    else
        vim.lsp.buf.format()
    end
end
vim.keymap.set('n', '<leader><leader>', prettify)


vim.keymap.set('n', 'gr', function() require('telescope.builtin').lsp_references() end, { noremap = true, silent = true })
vim.keymap.set('n', 'gR', function() require('telescope.builtin').lsp_implementations() end,
    { noremap = true, silent = true })
vim.keymap.set('n', 'gw', function() require('telescope.builtin').lsp_incoming_calls() end,
    { noremap = true, silent = true })
vim.keymap.set('n', 'gb', "<cmd>bnext<cr>")
vim.keymap.set('n', 'gB', "<cmd>bprev<cr>")
------
local getNextBuff = "<cmd>bnext<CR>"
vim.keymap.set("n", "gt", getNextBuff)
vim.keymap.set("n", "gT", "<cmd>bprev<CR>")
-- vim.keymap.set("n", "gt", "<cmd>tabnext<CR>")
-- vim.keymap.set("n", "gT", "<cmd>tabprevious<CR>")
-----


local function closeCurrentBuff()
    local nvimTree = require('nvim-tree.view')
    local wasTreeOpen = nvimTree.is_visible()

    vim.cmd("NvimTreeClose")
    vim.cmd("bd")

    if wasTreeOpen then
        vim.cmd("NvimTreeToggle")
        vim.cmd("bnext")
    end
end

vim.keymap.set('n', '<C-q>', closeCurrentBuff)
vim.keymap.set('n', '<C-w>', '<C-q>')

local function closeAllBuffersButCurrentOne()
    local nvimTree = require('nvim-tree.view')
    local wasTreeOpen = nvimTree.is_visible()
    vim.cmd("NvimTreeClose")

    local bufs = vim.api.nvim_list_bufs()

    local current_buf = vim.api.nvim_get_current_buf()
    for _, i in ipairs(bufs) do
        if i ~= current_buf then
            vim.api.nvim_buf_delete(i, {})
        end
    end
    if wasTreeOpen then
        vim.cmd("NvimTreeOpen")
    end
    vim.cmd("bnext")
end

vim.keymap.set('n', '<leader>Q', closeAllBuffersButCurrentOne)

-- Blammer
vim.keymap.set('n', '<leader>go', "<cmd>GitBlameOpenCommitURL<cr>")
-- Beautify
vim.keymap.set("n", "<leader>bf", "<cmd>%!js-beautify<cr>")


--- Trouble
local trouble = require("trouble")
local function troubleMaker(action)
    trouble.toggle(action)
end
vim.keymap.set("n", "<leader>xx", troubleMaker)
vim.keymap.set("n", "<leader>xw", function() troubleMaker("workspace_diagnostics") end)
vim.keymap.set("n", "<leader>xd", function() troubleMaker("document_diagnostics") end)
vim.keymap.set("n", "<leader>xq", function() troubleMaker("quickfix") end)
vim.keymap.set("n", "<leader>xl", function() troubleMaker("loclist") end)
vim.keymap.set("n", "gR", function() troubleMaker("lsp_references") end)


-- Copilot
vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

-- Spectre
vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").toggle()<CR>', {
    desc = "Toggle Spectre"
})
vim.keymap.set('n', '<leader>sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
    desc = "Search current word"
})
vim.keymap.set('v', '<leader>sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
    desc = "Search current word"
})
vim.keymap.set('n', '<leader>sp', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
    desc = "Search on current file"
})
vim.keymap.set("n", "<leader>d", function() vim.diagnostic.open_float() end)
