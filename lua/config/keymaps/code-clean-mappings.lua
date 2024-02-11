
vim.keymap.set('n', '<leader>qf', "<cmd>lua vim.lsp.buf.code_action()<CR>")
local function prettify()
    if vim.fn.exists(':EslintFixAll') > 0 then
        vim.cmd("EslintFixAll")
    else
        vim.lsp.buf.format()
    end
end
vim.keymap.set('n', '<leader><leader>', prettify)


-- Blammer
vim.keymap.set('n', '<leader>go', "<cmd>GitBlameOpenCommitURL<cr>")
-- Beautify
vim.keymap.set("n", "<leader>bf", "<cmd>%!js-beautify<cr>")
