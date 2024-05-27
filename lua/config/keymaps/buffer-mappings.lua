-- Buffer navigation
vim.keymap.set("n", "<C-J>", "<C-W><C-J>")
vim.keymap.set("n", "<C-K>", "<C-W><C-K>")
vim.keymap.set("n", "<C-H>", "<C-W><C-H>")
vim.keymap.set("n", "<C-L>", "<C-W><C-L>")

-- """""""" GO TO PREV FILE """"""""""""""
vim.keymap.set("n", "<leader>bb", "<C-^><cr>")

-- """""""" GO TO IMPLEMENTATION """""""""
vim.keymap.set("n", "gd", vim.lsp.buf.implementation)

----------------------------------------------------
vim.api.nvim_create_user_command("Cppath", function()
    local path = vim.fn.expand("%")
    vim.fn.setreg("+", path)
    vim.notify('Copied "' .. path .. '" to the clipboard!')
end, {})
vim.keymap.set("n", "<C-C>", "<cmd>Cppath<CR>")
----------------------------------------------------

vim.keymap.set("n", "<leader>n", "<cmd>NvimTreeToggle<CR>")

vim.keymap.set('n', 'gb', "<cmd>bnext<cr>")
vim.keymap.set('n', 'gB', "<cmd>bprev<cr>")
------
vim.keymap.set("n", "gt", "<cmd>bnext<CR>")
vim.keymap.set("n", "gT", "<cmd>bprev<CR>")
-- vim.keymap.set("n", "gt", "<cmd>tabnext<CR>")
-- vim.keymap.set("n", "gT", "<cmd>tabprevious<CR>")
-----


-- Close current
local function closeCurrentBuff()
    vim.cmd("NvimTreeClose")
    vim.cmd("bd")
end

vim.keymap.set('n', '<C-q>', closeCurrentBuff)
vim.keymap.set('n', '<C-w>', closeCurrentBuff)

-- Close others
local function closeAllBuffersButCurrentOne()
    vim.print(vim.fn.expand('%'))
    if string.find(vim.fn.expand('%'), vim.fn.expand('%')) then
        vim.print("Cant close all while focusing on the NVIM TREE MF")
    else
        local was_open = require 'nvim-tree.view'.is_visible()

        if was_open then
            vim.cmd("NvimTreeClose")
        end

        local bufs = vim.api.nvim_list_bufs()

        local current_buf = vim.api.nvim_get_current_buf()
        for _, i in ipairs(bufs) do
            if i ~= current_buf then
                vim.api.nvim_buf_delete(i, {})
            end
        end

        if was_open then
            vim.cmd("NvimTreeOpen")
            vim.cmd("bnext")
        end
    end
end
vim.keymap.set('n', '<leader>Q', closeAllBuffersButCurrentOne)
vim.keymap.set('n', '<leader>W', closeAllBuffersButCurrentOne)
