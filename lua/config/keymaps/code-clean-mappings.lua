vim.keymap.set('n', '<leader>qf', "<cmd>lua vim.lsp.buf.code_action()<CR>")
local function prettify()
    vim.lsp.buf.format()
    local filetype = vim.bo.filetype
    -- Check if Biome is installed and available
    if vim.fn.exists(':EslintFixAll') > 0 then
        vim.cmd("EslintFixAll")
    elseif filetype == "typescript" or filetype == "javascript" then
        -- Call Biome to format the code and apply fixes
        local current_file = vim.api.nvim_buf_get_name(0)
        vim.cmd(
            "!biome check" ..
            current_file
        )
    else
        vim.lsp.buf.format()
    end
    vim.cmd("w")
end
vim.keymap.set('n', '<leader><leader>', prettify)


-- Blammer
vim.keymap.set('n', '<leader>go', "<cmd>GitBlameOpenCommitURL<cr>")
-- Beautify
vim.keymap.set("n", "<leader>bf", "<cmd>%!js-beautify<cr>")
