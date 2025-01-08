local handle_process_selection = require('personal.utils').handle_process_selection
local function clean_branch_name(branch_string)
    return branch_string:match("%s*(.+)$")
end

vim.api.nvim_create_user_command('BranchCheckoutCurrentLine', function()
    local line = vim.api.nvim_get_current_line()
    local buff_row = vim.api.nvim_win_get_cursor(0)[1]
    local first_char = string.sub(line, 1, 1)
    local line_length = string.len(line)
    if line_length < 2 or first_char == "*" or first_char == "-" or buff_row < 3 then
        return
    end

    local branch_name = clean_branch_name(line)
    if branch_name then
        vim.cmd("Git checkout " .. branch_name) -- Checkout the selected branch
        vim.cmd("BranchToggle")
    end
end, {})

local function add_highlights(lines, window_buffer)
    local highlight_group = "Tag"

    if not lines or #lines == 0 then
        return
    end

    if not window_buffer then
        return
    end

    -- Apply highlights to each line of branches
    for i = 4, #lines - 1 do -- Start from line 2 to skip top padding
        local is_active = string.find(lines[i], '*')
        if is_active then
            vim.api.nvim_buf_add_highlight(window_buffer, -1,
                highlight_group, i - 1, 0, -1)
        end
    end
end

vim.api.nvim_create_user_command('BranchDeleteCurrentLine', function()
    local line = vim.api.nvim_get_current_line()
    local buff_row = vim.api.nvim_win_get_cursor(0)[1]
    local first_char = string.sub(line, 1, 1)
    local line_length = string.len(line)
    if line_length < 2 or first_char == "*" or first_char == "-" or buff_row < 3 then
        return
    end
    local branch_name = clean_branch_name(line)
    if branch_name then
        vim.cmd("Git branch -D " .. branch_name) -- Delete the selected branch
        vim.cmd("BranchToggle")
    end
end, {})

vim.api.nvim_create_user_command('BranchDeleteCurrentLine', function()
    handle_process_selection("Git branch -D", clean_branch_name, function()
        vim.cmd("BranchToggle")
    end)
end, {})

local function add_keymaps(window_buffer, local_branches)
    if local_branches then
        vim.api.nvim_buf_set_keymap(window_buffer, 'n', '<leader>d', "<cmd>BranchDeleteCurrentLine<CR>",
            { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(window_buffer, 'v', '<leader>d', "<cmd>BranchDeleteCurrentLine<CR>",
            { noremap = true, silent = true })
    end

    vim.api.nvim_buf_set_keymap(window_buffer, 'n', '<s-M>', "<cmd>BranchMergeCurrentLine<CR>",
        { noremap = true, silent = true })
end

local function on_buffer_load(lines, window_buffer, local_branches)
    add_highlights(lines, window_buffer)
    add_keymaps(window_buffer, local_branches)
end

local function on_buffer_load_local(lines, window_buffer)
    on_buffer_load(lines, window_buffer, true)
end

local docs_local = [[
*branch-management*                             *branch-management*

==============================================================================
** Branch Management **
==============================================================================

      <CR> or <Enter>      Toggle stage/unstage branch
      <leader>d            `git branch -D <cursor line or selection>`
      <s-M>                `git merge <cursor line>`

]]

local docs_remote = [[
*branch-management*                             *branch-management*

==============================================================================
** Branch Management **
==============================================================================

      <CR> or <Enter>      Toggle stage/unstage branch
      <s-M>                `git merge <cursor line>`

]]

local local_branches = {
    label = "Local Branches",
    command = "git branch",
    on_enter = "BranchCheckoutCurrentLine",
    header = "Branches - Local",
    on_buffer_load = on_buffer_load_local,
    docs = docs_local,
}

local remote_branches = {
    label = "Remote Branches",
    command = "git branch -r",
    on_enter = "BranchCheckoutCurrentLine",
    header = "Branches - Remote",
    on_buffer_load = on_buffer_load,
    docs = docs_remote,
}

local M = {}
M.local_branches = local_branches
M.remote_branches = remote_branches

return M
