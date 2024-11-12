local remote_branches_label = " Remote branches"
local local_branches_label = " Local branches"
local last_width = 0
local last_height = 0
-- Helper function to checkout the branch
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

vim.api.nvim_create_user_command("Branch", function(params)
    local remote = params.args == "remote"
    -- Run the git branch command and capture output
    local command = remote and "git branch -r" or "git branch"
    local handle = io.popen(command)
    if handle == nil then
        return
    end

    local result = handle:read("*a")
    handle:close()

    -- Define window dimensions and position
    local width = 10
    local height = 10

    -- Split output into lines
    local lines = {}
    for line in result:gmatch("[^\r\n]+") do
        local new_line = " " .. line
        table.insert(lines, new_line)
        if #new_line > width then
            width = #new_line
        end
    end
    table.insert(lines, '')

    height = #lines + 3
    if height > last_height then
        last_height = height
    end

    width = width + 4
    if width > last_width then
        last_width = width
    end

    local row = math.floor((vim.o.lines - last_height) / 2)
    local col = math.floor((vim.o.columns - last_width) / 2)

    local header = 'Branches'
    local padding_spaces = "-"
    local line_padding = math.floor(((last_width - #header) / 2))
    local padded_header = string.rep(padding_spaces, line_padding) .. header .. string.rep(padding_spaces, line_padding)
    table.insert(lines, 1, padded_header)
    table.insert(lines, 2, remote and local_branches_label or remote_branches_label)
    table.insert(lines, 3, "")



    -- Define buffer
    local buf = vim.api.nvim_create_buf(false, true) -- Create a new buffer that is not listed and is scratch

    -- Set buffer content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Define action on <CR>
    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', "<cmd>BranchCheckoutCurrentLine<CR>",
        { noremap = true, silent = true })

    -- Create floating window with buffer
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = last_width,
        height = last_height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded'
    })

    -- Set keymaps to close the modal
    local keymaps = {
        'q', '<Esc>', '<C-c>'
    }
    for _, key in ipairs(keymaps) do
        vim.api.nvim_buf_set_keymap(buf, 'n', key, ':close<CR>', { noremap = true, silent = true })
    end

    -- Set an autocommand to close the window when it loses focus
    vim.api.nvim_create_autocmd("WinLeave", {
        buffer = buf,
        once = true,
        callback = function()
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
            end
        end,
    })
end, {
    nargs = '*',
})
