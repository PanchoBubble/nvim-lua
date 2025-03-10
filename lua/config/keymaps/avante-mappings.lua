local M = {}

-- Define Avante buffer detection
function M.is_avante_buffer(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].filetype
    return ft == "avante"
end

-- Define Avante-specific mappings
function M.setup_avante_mappings(bufnr)
    local opts = { buffer = bufnr, silent = true }

    -- Override default mappings for Avante buffers
    -- Add your Avante-specific mappings here
    vim.keymap.set('n', '<leader>r', function()
        -- Add Avante-specific run command
        vim.notify("Running Avante command...", vim.log.levels.INFO)
    end, opts)

    -- Add more Avante-specific mappings as needed
end

-- Setup autocommand to apply Avante mappings
vim.api.nvim_create_autocmd("FileType", {
    pattern = "avante",
    callback = function(args)
        M.setup_avante_mappings(args.buf)
    end,
})

return M

