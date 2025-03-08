-- Function to create a centered floating window
local function create_centered_floating_window(title)
    local width = 60
    local height = 1
    local win_height = vim.o.lines
    local win_width = vim.o.columns
    local row = math.floor((win_height - height) / 2 - 1)
    local col = math.floor((win_width - width) / 2)

    local opts = {
        style = "minimal",
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = "rounded",
        title = " " .. title .. " ",
        title_pos = "center",
    }

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, opts)

    -- Set window-local options
    vim.wo[win].wrap = false
    vim.bo[buf].buftype = "prompt"

    return buf, win
end

-- Function to execute git commands and handle errors
local function execute_git_command(cmd, silent)
    local output = vim.fn.systemlist(cmd)
    local success = vim.v.shell_error == 0

    if not success and not silent then
        -- Create a floating window for error display
        local buf = vim.api.nvim_create_buf(false, true)
        local width = math.min(120, vim.o.columns - 4)
        local height = math.min(#output + 2, 20)

        local opts = {
            relative = "editor",
            width = width,
            height = height,
            row = math.floor((vim.o.lines - height) / 2),
            col = math.floor((vim.o.columns - width) / 2),
            style = "minimal",
            border = "rounded",
            title = " Git Error ",
            title_pos = "center",
        }

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
        local win = vim.api.nvim_open_win(buf, true, opts)
        vim.bo[buf].modifiable = false
        vim.bo[buf].buftype = "nofile"

        -- Close window on any key press
        vim.keymap.set("n", "<space>", function()
            vim.api.nvim_win_close(win, true)
        end, { buffer = buf, nowait = true })
        vim.keymap.set("n", "<esc>", function()
            vim.api.nvim_win_close(win, true)
        end, { buffer = buf, nowait = true })
        vim.keymap.set("n", "q", function()
            vim.api.nvim_win_close(win, true)
        end, { buffer = buf, nowait = true })
    end

    return success, output
end

vim.keymap.set("n", "<leader>ca", "<cmd>GitAddAndCommitAll<CR>")

vim.api.nvim_create_user_command("GitAddAndCommitAll",
    function()
        local buf, win = create_centered_floating_window("Commit Message")
        local commit_message = ""

        -- Set up the prompt callback
        vim.fn.prompt_setcallback(buf, function(input)
            if input and input ~= "" then
                commit_message = input
                vim.api.nvim_win_close(win, true)

                -- Get current branch
                local success, branch_output = execute_git_command("git branch --show-current", true)
                if not success then
                    vim.notify("Error: Could not determine the current branch", vim.log.levels.ERROR)
                    return
                end
                local current_branch = branch_output[1]

                -- Execute git commands
                local commands = {
                    { cmd = "git add .",                                                            msg = "Adding files..." },
                    { cmd = string.format([[git commit -m "%s"]], commit_message:gsub('"', '\\"')), msg = "Committing..." },
                    { cmd = "git pull --no-edit",                                                   msg = "Pulling changes..." },
                }

                for _, command in ipairs(commands) do
                    vim.notify(command.msg, vim.log.levels.INFO)
                    local success, output = execute_git_command(command.cmd)
                    if not success then
                        return
                    end
                end

                -- Check if branch exists on remote
                local success, remote_check = execute_git_command("git ls-remote --heads origin " .. current_branch, true)
                local push_command = #remote_check == 0
                    and "git push --set-upstream origin " .. current_branch
                    or "git push"

                vim.notify("Pushing changes...", vim.log.levels.INFO)
                local success, _ = execute_git_command(push_command)
                if success then
                    vim.notify("Successfully committed and pushed: " .. commit_message, vim.log.levels.INFO)
                end
            else
                vim.api.nvim_win_close(win, true)
                vim.notify("Commit cancelled", vim.log.levels.WARN)
            end
        end)

        -- Start prompt
        vim.fn.prompt_setprompt(buf, "")
        vim.cmd("startinsert")
    end,
    {}
)

vim.keymap.set("n", "<leader>co", "<cmd>GitCheckoutNewBranch<CR>")
vim.api.nvim_create_user_command("GitCheckoutNewBranch",
    function()
        -- Use vim.ui.input to prompt the user
        vim.ui.input({ prompt = "Branch name: " }, function(input)
            if input then
                vim.cmd("Git checkout -b " .. input)
                vim.print("Checked out new branch: " .. input)
            else
                print("Prompt cancelled")
            end
        end)
    end,
    {})

vim.keymap.set("n", "<leader>gp", "<cmd>Git pull --no-edit<CR>")

vim.keymap.set("n", "<leader>p", "<cmd>GitPushNewBranch<CR>")
vim.api.nvim_create_user_command("GitPushNewBranch",
    function()
        local current_branch = vim.fn.systemlist("git branch --show-current")[1]
        if not current_branch then
            print("Error: Could not determine the current branch")
            return
        end
        -- Check if the branch exists on the remote
        local remote_branch_exists = vim.fn.systemlist("Git ls-remote --heads origin " .. current_branch)

        if #remote_branch_exists == 0 then
            -- Branch does not exist on the remote, push with --set-upstream
            vim.cmd("!git push --set-upstream origin " .. current_branch)
        else
            -- Branch exists, normal push
            vim.cmd("Git push")
        end
    end,
    {})
