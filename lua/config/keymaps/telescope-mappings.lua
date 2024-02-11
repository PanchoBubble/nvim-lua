vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>")

vim.keymap.set("n", "<C-p>", "<cmd>Telescope find_files<CR>")

vim.keymap.set("n", "<leader>fw", function()
    return "<cmd>Telescope live_grep default_text=" .. vim.fn.expand("<cword>") .. "<CR>"
end, { expr = true })

local function handle_live_grep()
    local conf = require('telescope.config').values
    require('telescope.builtin').live_grep {
        vimgrep_arguments = table.insert(conf.vimgrep_arguments, '--fixed-strings'),
    }
end
vim.keymap.set("n", "<C-f>", handle_live_grep)

vim.keymap.set('n', 'gr', function() require('telescope.builtin').lsp_references() end, { noremap = true, silent = true })
vim.keymap.set('n', 'gR', function() require('telescope.builtin').lsp_implementations() end,
    { noremap = true, silent = true })
vim.keymap.set('n', 'gw', function() require('telescope.builtin').lsp_incoming_calls() end,
    { noremap = true, silent = true })
