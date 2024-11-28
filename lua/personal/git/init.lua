require('personal.git.branch')
local local_branches = require('personal.git.branch').local_branches
local remote_branches = require('personal.git.branch').remote_branches
local status = require('personal.git.status')

local imported_tabs = {
    status,
    local_branches,
    remote_branches,
}

local tabs = {}
for key, tab in pairs(imported_tabs) do
    local tab_copy = vim.deepcopy(tab) -- Create a copy of the tab
    tab_copy.value = key
    tab_copy.on_buffer_load = tab.on_buffer_load
    tab_copy.label = "[" .. key .. "] " .. tab.label -- Add the value to the label
    table.insert(tabs, tab_copy)                     -- Add the imported tab to the table
end

local active_tab = tabs[1]

local view_width = 0
local view_height = 0
local window_buffer = nil
local floating_window = nil
local lines = {}

local function get_active_tab(value)
    for index, tab in ipairs(tabs) do
        if tostring(index) == tostring(value) then
            return tab
        end
    end
    return nil
end

vim.api.nvim_create_user_command('BranchToggle', function(view)
    local tab_number = view.args
    if tab_number then
        active_tab = get_active_tab(tab_number) or tabs[1]
    end
    vim.cmd("close")
    vim.cmd("Branch")
end, {
    nargs = '*',
})

vim.api.nvim_create_user_command('BranchToggle', function(view)
    local tab_number = view.args
    active_tab = get_active_tab(tab_number) or tabs[1]
    vim.cmd("close")
    vim.cmd("Branch")
end, {
    nargs = '*',
})


local function add_header()
    local header = active_tab.header
    if active_tab.docs then
        header = header .. " | [?] Docs"
    end
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



vim.api.nvim_create_user_command('BranchDocs', function()
    if active_tab.docs == nil then
        return
    end

    vim.print(active_tab.docs)
end, {})

local function add_buffer_keymaps()
    if window_buffer == nil then
        return
    end

    -- Define toggles
    for _, tab in ipairs(tabs) do
        vim.api.nvim_buf_set_keymap(window_buffer, 'n', tostring(tab.value),
            "<cmd>BranchToggle " .. tostring(tab.value) .. "<CR>",
            { noremap = true, silent = true })
    end

    vim.api.nvim_buf_set_keymap(window_buffer, 'n', '?',
        "<cmd>BranchDocs<CR>",
        { noremap = true, silent = true })

    -- Define action on <CR>
    local command = "<cmd>" .. active_tab.on_enter .. "<CR>"
    vim.api.nvim_buf_set_keymap(window_buffer, 'n', '<CR>', command,
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

    -- Ensure the row is within the bounds of the screen

    add_header()

    -- Define buffer
    window_buffer = vim.api.nvim_create_buf(false, true) -- Create a new buffer that is not listed and is scratch

    -- Set buffer content
    vim.api.nvim_buf_set_lines(window_buffer, 0, -1, false, lines)

    local row = math.max(math.floor((vim.o.lines - view_height) / 2), 3)
    local col = math.floor((vim.o.columns - view_width) / 2)

    -- Create floating window with buffer
    floating_window = vim.api.nvim_open_win(window_buffer, true, {
        relative = 'editor',
        width = view_width,
        height = math.min(view_height, vim.o.lines - 10),
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded'
    })

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

    add_buffer_keymaps()

    active_tab.on_buffer_load(lines, window_buffer)

    -- Restrict the buffer in the floating window
    vim.api.nvim_buf_set_option(window_buffer, "readonly", true)
    vim.api.nvim_buf_set_option(window_buffer, "modifiable", false)                     -- Prevent editing
    vim.api.nvim_buf_set_option(window_buffer, "bufhidden", "hide")                     -- Handle close behavior
    vim.api.nvim_win_set_option(floating_window, "number", false)                         -- Disable line numbers
    vim.api.nvim_win_set_option(floating_window, "relativenumber", false)                 -- Disable relative line numbers
end, {
    nargs = '*',
})
