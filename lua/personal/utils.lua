--- Helper function to process a line
--- @param line_command string The command to execute on the line
--- @param clean_file_path fun(line: string): string|nil A function to clean the file path
--- @param on_end fun() A function to execute after the process is complete
local function handle_process_selection(line_command, clean_file_path, on_end)
    --- Process a single line
    --- @param line string The content of the line
    --- @param buff_row integer The line number in the buffer
    local function process_line(line, buff_row)
        local first_char = string.sub(line, 1, 1)
        local line_length = string.len(line)
        if line_length < 2 or first_char == "*" or first_char == "-" or buff_row < 3 then
            return
        end
        local file_path = clean_file_path(line)
        if file_path then
            vim.cmd(line_command .. " " .. file_path)
        end
    end

    -- Check for visual selection
    local mode = vim.fn.mode()
    if mode == "v" or mode == "V" or mode == "" then
        -- Visual mode: Get selected lines
        local start_pos = vim.fn.getpos("v")[2]
        local end_pos = vim.fn.getpos(".")[2]
        local lines = vim.api.nvim_buf_get_lines(0, start_pos - 1, end_pos, false)

        -- Process each selected line
        for i, line in ipairs(lines) do
            local buff_row = start_pos + i - 1
            process_line(line, buff_row)
        end
    else
        -- No selection: Process the current line
        local line = vim.api.nvim_get_current_line()
        local buff_row = vim.api.nvim_win_get_cursor(0)[1]
        process_line(line, buff_row)
    end

    on_end()
end


local M = {}
M.handle_process_selection = handle_process_selection

return M
