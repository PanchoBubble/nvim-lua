local not_staged_line_number = 0

local function clean_file_path(branch_string)
    local clean_string = branch_string:gsub("modified:", "")
    clean_string = clean_string:gsub("new file:", "")
    return clean_string:match("%s*(.+)$")
end

vim.api.nvim_create_user_command('BranchFileToggleStaged', function()
    local line = vim.api.nvim_get_current_line()
    local buff_row = vim.api.nvim_win_get_cursor(0)[1]
    local add = buff_row > not_staged_line_number

    local command = add and "Git add" or "Git reset"
    local file_path = clean_file_path(line)
    vim.print(file_path)

    if file_path then
        vim.cmd(command .. " ./" .. file_path)
        vim.cmd("close")
        vim.cmd("Branch")
    end
end, {})

local function add_highlights(lines, window_buffer)
    local highlight_group_tag = "Tag"
    local highlight_group_added = "Added"
    local highlight_group_keyword = "Keyword"
    local not_staged = false
    local untracked = false

    if not lines or #lines == 0 then
        print("No lines")
        return
    end

    if not window_buffer then
        print("No window buffer")
        return
    end

    print(window_buffer, lines)

    -- Apply highlights to each line of branches
    for i = 4, #lines - 1 do -- Start from line 2 to skip top padding
        local add_color = false
        local highlight = "Tag"
        local new_file = string.find(lines[i], 'new file')
        if new_file then
            add_color = true
            highlight = highlight_group_tag
        end


        if string.find(lines[i], 'not staged') then
            not_staged = true
            not_staged_line_number = i
        end

        local modified = string.find(lines[i], 'modified')

        if modified then
            add_color = true
            if not_staged then
                highlight = highlight_group_keyword
            else
                highlight = highlight_group_added
            end
        end

        if add_color then
            vim.api.nvim_buf_add_highlight(window_buffer, -1, highlight, i - 1, 0, -1)
        end

        if untracked then
            vim.api.nvim_buf_add_highlight(window_buffer, -1, highlight_group_keyword, i - 1, 0, -1)
        end

        if string.find(lines[i], 'Untracked files') then
            untracked = true
        end
    end
end

vim.api.nvim_create_user_command('BranchAddAll', function()
    vim.cmd("Git add .")
    vim.cmd("BranchToggle")
end, {})

vim.api.nvim_create_user_command('BranchResetAll', function()
    vim.cmd("Git reset .")
    vim.cmd("BranchToggle")
end, {})

vim.api.nvim_create_user_command('BranchCommit', function()
    vim.cmd("close")
    vim.cmd("Git commit")
end, {})

vim.api.nvim_create_user_command('BranchStashPop', function()
    vim.cmd("Git stash pop")
    vim.cmd("BranchToggle")
end, {})

vim.api.nvim_create_user_command('BranchStashCurrentLine', function()
    local line = vim.api.nvim_get_current_line()
    local file_path = clean_file_path(line)
    vim.cmd("Git stash save " .. file_path)
    vim.cmd("BranchToggle")
end, {})

vim.api.nvim_create_user_command('BranchCommit', function()
    vim.cmd("close")
    vim.cmd("Git commit")
end, {})

local function add_keymaps(window_buffer)
    vim.api.nvim_buf_set_keymap(window_buffer, 'n', 'c', "<cmd>BranchCommit<CR>",
        { noremap = true, silent = true })

    vim.api.nvim_buf_set_keymap(window_buffer, 'n', 'a', "<cmd>BranchAddAll<CR>",
        { noremap = true, silent = true })

    vim.api.nvim_buf_set_keymap(window_buffer, 'n', 'ra', "<cmd>BranchResetAll<CR>",
        { noremap = true, silent = true })

    vim.api.nvim_buf_set_keymap(window_buffer, 'n', 's', "<cmd>BranchResetAll<CR>",
        { noremap = true, silent = true })

    vim.api.nvim_buf_set_keymap(window_buffer, 'n', 'pop', "<cmd>BranchResetAll<CR>",
        { noremap = true, silent = true })
end

local function on_buffer_load(lines, window_buffer)
    add_highlights(lines, window_buffer)
    add_keymaps(window_buffer)
end

-- Define and return module table
local M = {}
M.label = "Status"
M.command = "git status"
M.on_enter = "BranchFileToggleStaged"
M.header = "Status"
M.on_buffer_load = on_buffer_load

return M