-- vim.keymap.set("n", "<leader>fw", function()
--     return "<cmd>Telescope live_grep default_text=" .. vim.fn.expand("<cword>") .. "<CR>"
-- end, { expr = true })
--
local get_telescope_args = function()
    local conf = require('telescope.config').values
    local vimgrep_arguments = vim.deepcopy(conf.vimgrep_arguments)
    table.insert(vimgrep_arguments, '--fixed-strings')
    table.insert(vimgrep_arguments, '--hidden')
    return vimgrep_arguments
end

local function handle_live_grep(default_text)
    local vimgrep_arguments = get_telescope_args()
    require('telescope.builtin').live_grep {
        vimgrep_arguments = vimgrep_arguments,
        prompt_title = '  Find Word',
        default_text = default_text,
    }
end
vim.keymap.set("n", "<C-f>", handle_live_grep)
vim.keymap.set("n", "<leader>fw", function()
    local default_text = vim.fn.expand("<cword>")
    return handle_live_grep(default_text)
end)

local hadle_find_files = function()
    require('telescope.builtin').find_files {
        find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
        prompt_title = '  Find File',
    }
end
vim.keymap.set("n", "<C-p>", hadle_find_files)

vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>")


vim.keymap.set('n', 'gr', function() require('telescope.builtin').lsp_references() end, { noremap = true, silent = true })
vim.keymap.set('n', 'gR', function() require('telescope.builtin').lsp_implementations() end,
    { noremap = true, silent = true })
vim.keymap.set('n', 'gw', function() require('telescope.builtin').lsp_incoming_calls() end,
    { noremap = true, silent = true })
