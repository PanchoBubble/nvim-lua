local local_branches = {
    label = "[1] Local",
    value = '1',
    command = "git branch",
}

local remote_branches = {
    label = "[2] Remote",
    value = '2',
    command = "git branch -r",
}

local branch_status = {
    label = "[3] Status",
    value = '3',
    command = "git status",
    on_enter = "BranchToggleStaged",
}

local tabs = {
    local_branches,
    remote_branches,
    branch_status
}

local active_tab = local_branches
local untracked_line_number = 0

local view_width = 0
local view_height = 0
local window_buffer = nil
local floating_window = nil
local lines = {}

local function get_active_tab(value)
    for _, tab in ipairs(tabs) do
        if tab.value == value then
            return tab
        end
    end
    return nil
end

vim.api.nvim_create_user_command('BranchToggle', function(view)
    local tab_number = view.args
    active_tab = get_active_tab(tab_number) or local_branches
    vim.cmd("close")
    vim.cmd("Branch")
end, {
    nargs = '*',
})

vim.api.nvim_create_user_command('BranchToggleStaged', function()
    local line = vim.api.nvim_get_current_line()
    local buff_row = vim.api.nvim_win_get_cursor(0)[1]
    local add = buff_row > untracked_line_number

    local command = add and "Git add" or "Git reset"
    local branch_name = line:gsub("modified:", ""):match("%s*(.+)$")  -- Extract branch name from line
    vim.print(branch_name)

    if branch_name then
        vim.cmd(command .. " ./" .. branch_name) -- Checkout the selected branch
        vim.cmd("close")
        vim.cmd("Branch")
    end
end, {})

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

local function add_header()
    local header = 'Branches'
    local padding_spaces = "-"
    local line_padding = math.floor(((view_width - #header) / 2))
    local padded_header = string.rep(padding_spaces, line_padding) .. header .. string.rep(padding_spaces, line_padding)
    table.insert(lines, 1, padded_header)

    local tab_string = ''
    for _, tab in ipairs(tabs) do
        tab_string = tab_string .. tab.label .. ' '
    end

    table.insert(lines, 2, "")
    table.insert(lines, 3, tab_string)
    table.insert(lines, 4, "")
end



local function add_buffer_keymaps()
    if window_buffer == nil then
        return
    end

    -- Define toggles
    for _, tab in ipairs(tabs) do
        vim.api.nvim_buf_set_keymap(window_buffer, 'n', tab.value, "<cmd>BranchToggle " .. tab.value .. "<CR>",
            { noremap = true, silent = true })
    end

    -- Define action on <CR>
    local command = active_tab.on_enter or "BranchCheckoutCurrentLine"
    vim.api.nvim_buf_set_keymap(window_buffer, 'n', '<CR>', "<cmd>" .. command .. "<CR>",
        { noremap = true, silent = true })
    -- Set keymaps to close the modal
    local keymaps = {
        'q', '<Esc>', '<C-c>'
    }
    for _, key in ipairs(keymaps) do
        vim.api.nvim_buf_set_keymap(window_buffer, 'n', key, ':close<CR>', { noremap = true, silent = true })
    end

    ------------------------------------------
    ---
    if floating_window == nil then
        return
    end

    -- Set an autocommand to close the window when it loses focus
    vim.api.nvim_create_autocmd("WinLeave", {
        buffer = window_buffer,
        once = true,
        callback = function()
            if vim.api.nvim_win_is_valid(floating_window) then
                vim.api.nvim_win_close(floating_window, true)
            end
        end,
    })
end

local function get_branches()
    local command = active_tab.command
    local handle = io.popen(command)
    if handle == nil then
        return
    end

    local result = handle:read("*a")
    handle:close()
    return result
end

local function format_and_set_lines(branches)
    local width = 0
    local height = 0
    -- Split output into lines
    lines = {}
    for line in branches:gmatch("[^\r\n]+") do
        if not string.find(line, '%(use "git') then
            local new_line = " " .. line
            table.insert(lines, new_line)
            if #new_line > width then
                width = #new_line
            end
        end
    end
    table.insert(lines, '')


    height = #lines + 4
    view_height = height

    width = width + 4
    if width > view_width then
        view_width = width
    end
end

vim.api.nvim_create_user_command("Branch", function()
    -- Run the git branch command and capture output
    local branches = get_branches()
    if branches == nil then
        return
    end

    -- Split output into lines
    format_and_set_lines(branches)

    local row = math.floor((vim.o.lines - view_height) / 2)
    local col = math.floor((vim.o.columns - view_width) / 2)

    add_header()

    -- Define buffer
    window_buffer = vim.api.nvim_create_buf(false, true) -- Create a new buffer that is not listed and is scratch

    -- Set buffer content
    vim.api.nvim_buf_set_lines(window_buffer, 0, -1, false, lines)

    -- Create floating window with buffer
    floating_window = vim.api.nvim_open_win(window_buffer, true, {
        relative = 'editor',
        width = view_width,
        height = view_height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded'
    })

    local highlight_group = "Tag"
    local not_staged = false
    local highlight_group_not_active = "Keyword"

    local highlight_from = 0
    local highlight_to = 0
    for _, tab in ipairs(tabs) do
        if tab.value == active_tab.value then
            highlight_to = highlight_from + #tab.label
            break
        end
        highlight_from = highlight_from + #tab.label + 1
    end
    -- Apply highlights to header
    vim.api.nvim_buf_add_highlight(window_buffer, -1, 'Todo', 0, 0, -1)
    vim.api.nvim_buf_add_highlight(window_buffer, -1, 'Title', 2, highlight_from, highlight_to)

    -- Apply highlights to each line of branches
    for i = 4, #lines - 1 do -- Start from line 2 to skip top padding
        local is_active = string.find(lines[i], '*') or string.find(lines[i], 'modified')
        if string.find(lines[i], 'not staged') then
            untracked_line_number = i
            not_staged = true
        end
        if is_active then
            vim.api.nvim_buf_add_highlight(window_buffer, -1,
                not_staged and highlight_group_not_active or highlight_group, i - 1, 0, -1)
        end
    end

    add_buffer_keymaps()
end, {
    nargs = '*',
})
