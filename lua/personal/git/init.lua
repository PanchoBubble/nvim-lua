local remote_branches_label = " Remote"
local local_branches_label = " Local"
local view_width = 0
local view_height = 0
local window_buffer = nil
local floating_window = nil
local remote = false
local lines = {}
-- Apply highlights to each line of branches
--   for i = 2, #lines - 1 do  -- Start from line 2 to skip top padding
--       vim.api.nvim_buf_add_highlight(buf, -1, highlight_group, i - 1, 0, -1)
--         end

vim.api.nvim_create_user_command('BranchCheckoutCurrentLine', function()
    local line = vim.api.nvim_get_current_line()
    local first_char = string.sub(line, 1, 1)
    local line_length = string.len(line)
    if line == local_branches_label then
        vim.cmd("close")
        vim.cmd("Branch")
        return
    end
    if line == remote_branches_label then
        vim.cmd("close")
        vim.cmd("Branch remote")
        return
    end
    if line_length < 2 or first_char == "*" or first_char == "-" then
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
    table.insert(lines, 2, remote and local_branches_label or remote_branches_label)
    table.insert(lines, 3, "")
end

local function add_buffer_keymaps()
    if window_buffer == nil then
        return
    end

    -- Define action on <CR>
    vim.api.nvim_buf_set_keymap(window_buffer, 'n', '<CR>', "<cmd>BranchCheckoutCurrentLine<CR>",

        ----------------------------------------
        ---
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
    local command = remote and "git branch -r" or "git branch"
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
    table.insert(lines, '')
    for line in branches:gmatch("[^\r\n]+") do
        local new_line = " " .. line
        table.insert(lines, new_line)
        if #new_line > width then
            width = #new_line
        end
    end
    table.insert(lines, '')


    height = #lines + 3
    if height > view_height then
        view_height = height
    end

    width = width + 4
    if width > view_width then
        view_width = width
    end
end

vim.api.nvim_create_user_command("Branch", function(params)
    remote = params.args == "remote"
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

    local highlight_group = "Keyword"
    local located_active_branch = nil
    -- Apply highlights to each line of branches
    for i = 4, #lines - 1 do -- Start from line 2 to skip top padding
        if not located_active_branch then
            local is_active = string.find(lines[i], '*')
            located_active_branch = is_active
            if is_active then
                vim.api.nvim_buf_add_highlight(window_buffer, -1, highlight_group, i - 1, 0, -1)
            end
        end
    end

    add_buffer_keymaps()
end, {
    nargs = '*',
})
