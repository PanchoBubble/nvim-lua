-- Helper function to checkout the branch
vim.api.nvim_create_user_command('BranchCheckoutCurrentLine', function()
    local line = vim.api.nvim_get_current_line()
    local first_char = string.sub(line, 1, 1)
    local line_length = string.len(line)
    if line_length < 2 or first_char == "*" or first_char == "-" then
        return
    end

    local branch_name = line:match("%s*(.+)$")  -- Extract branch name from line
    if branch_name then
        vim.cmd("Git checkout " .. branch_name) -- Checkout the selected branch
        vim.cmd("close")                        -- Close the floating window
        vim.cmd("Branch")
    end
end, {})

vim.api.nvim_create_user_command("Branch", function()
    -- Run the git branch command and capture output
    local handle = io.popen("git branch")
    if handle == nil then
        return
    end

    local result = handle:read("*a")
    handle:close()

    -- Define window dimensions and position
    local width = 10
    local height = 10
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

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

    height = #lines + 2
    width = width + 4

    local header = 'Branches'
    local padding_spaces = "-"
    local line_padding = math.floor(((width - #header) / 2))
    local padded_header = string.rep(padding_spaces, line_padding) .. header .. string.rep(padding_spaces, line_padding)
    table.insert(lines, 1, padded_header)
    table.insert(lines, 2, "")



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
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded'
    })

    -- Set keymap to close the modal
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', { noremap = true, silent = true })
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
end, {})
