vim.api.nvim_create_user_command('BranchCheckoutCurrentLine', function()
    local line = vim.api.nvim_get_current_line()
    local buff_row = vim.api.nvim_win_get_cursor(0)[1]
    local first_char = string.sub(line, 1, 1)
    local line_length = string.len(line)
    if line_length < 2 or first_char == "*" or first_char == "-" or buff_row < 3 then
        return
    end

    local branch_name = line:match("%s*(.+)$")  -- Extract branch name from line
    if branch_name then
        vim.cmd("Git checkout " .. branch_name) -- Checkout the selected branch
        vim.cmd("close")
        vim.cmd("Branch")
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


local function on_buffer_load(lines, window_buffer)
    add_highlights(lines, window_buffer)
end

local local_branches = {
    label = "Local Branches",
    command = "git branch",
    on_enter = "BranchCheckoutCurrentLine",
    header = "Branches - Local",
    on_buffer_load = on_buffer_load,
}

local remote_branches = {
    label = "Remote Branches",
    command = "git branch -r",
    on_enter = "BranchCheckoutCurrentLine",
    header = "Branches - Remote",
    on_buffer_load = on_buffer_load,
}

local M = {}
M.local_branches = local_branches
M.remote_branches = remote_branches

return M
