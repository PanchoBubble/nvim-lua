---@diagnostic disable: redefined-local

-- Helper function to create a centered floating window
-- Increased default height for prompts
local function create_centered_floating_window(title, initial_height)
    local width = math.floor(vim.o.columns * 0.6)
    local height = math.max(initial_height or 5, 1) -- Default height 5, min 1
    local win_height = vim.o.lines
    local win_width = vim.o.columns
    local row = math.floor((win_height - height) / 2)
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
        -- Make window resizable if you want (optional)
        -- zindex = 50,
    }

    local buf = vim.api.nvim_create_buf(false, true)      -- no file, scratch buffer
    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe') -- Close buffer when window closes

    -- Set window-local options
    vim.wo[win].wrap = false       -- Keep wrap off for prompts usually
    vim.bo[buf].buftype = "prompt" -- Important for vim.fn.prompt_setcallback

    -- Basic highlighting (optional)
    vim.api.nvim_win_set_option(win, 'winhl', 'Normal:NormalFloat,FloatBorder:FloatBorder')

    return buf, win
end

-- Refined helper function to execute shell commands synchronously
-- Returns: success (boolean), output_lines (table), exit_code (number)
local function execute_command(cmd, return_output, silent_execution)
    -- vim.notify("Executing: " .. cmd, vim.log.levels.DEBUG) -- Optional debug
    local output_lines = vim.fn.systemlist(cmd)
    local exit_code = vim.v.shell_error

    if exit_code ~= 0 and not silent_execution then
        -- Display error in a floating window (or use vim.notify for simplicity)
        local error_message = string.format("Command failed (code %d): %s", exit_code, cmd)
        if return_output and #output_lines > 0 then
            error_message = error_message .. "\nOutput:\n" .. table.concat(output_lines, "\n")
        elseif #output_lines > 0 then -- Also show output even if not requested on error
             error_message = error_message .. "\nOutput:\n" .. table.concat(output_lines, "\n")
        end
        -- Option 1: Simple Notification
        vim.notify(error_message, vim.log.levels.ERROR)
        -- Option 2: Floating Window (using a simplified version)
        -- local err_buf = vim.api.nvim_create_buf(false, true)
        -- vim.api.nvim_buf_set_lines(err_buf, 0, -1, false, vim.split(error_message, "\n"))
        -- vim.api.nvim_open_win(err_buf, true, {
        --     relative = "editor", width = 80, height = 10, border = "rounded", title = "Git Error"
        -- })
        -- vim.api.nvim_buf_set_option(err_buf, 'modifiable', false)

        return false, output_lines, exit_code
    end

    return exit_code == 0, output_lines, exit_code
end

-- Function to get AI-generated commit title and description using Google Gemini API
-- IMPORTANT: This function now ONLY reads the diff, it does NOT stage changes.
local function get_ai_title_and_description(currentTitle)
    vim.notify("Getting AI title and description via Gemini...")

    -- *** MODIFIED: Use GEMINI_API_KEY ***
    local api_key = os.getenv("GEMINI_API_KEY")
    if not api_key or api_key == "" then
        vim.notify("GEMINI_API_KEY environment variable not set", vim.log.levels.ERROR)
        return currentTitle, nil
    end

    -- Get staged diff ONLY. Rely on .gitignore to exclude node_modules etc.
    -- Add --diff-filter to ignore deleted files if desired (or keep default)
    local success, diff_output, exit_code = execute_command(
        "git diff --cached --no-prefix --diff-filter=AMDRC", true, true) -- return output, silent execution

    if not success and exit_code ~= 0 then -- Ignore exit code 0 which means success even if diff is empty
        vim.notify("Failed to get git diff (code: " .. exit_code .. ")", vim.log.levels.ERROR)
        return currentTitle, nil
    end

    if #diff_output == 0 then
        vim.notify("No staged changes found to generate commit message from.", vim.log.levels.WARN)
        vim.notify("Please stage the changes you want included first.", vim.log.levels.INFO)
        return currentTitle, nil
    end

    local diff_content = table.concat(diff_output, "\n")
    local max_diff_length = 15000 -- Adjust as needed (Gemini has context limits too)
    if #diff_content > max_diff_length then
        diff_content = diff_content:sub(1, max_diff_length)
        vim.notify("Diff content truncated to " .. max_diff_length .. " characters", vim.log.levels.WARN)
    end

    -- Prepare the prompt for Gemini (Same prompt structure should work)
    local prompt_text = string.format([[
Based on the following git diff of *staged* changes, please provide:
1. A concise, conventional commit style title (e.g., "feat: Add X", "fix: Y", "refactor: Z"). Max 50 chars.
2. A detailed description of the changes (what/why). Max 500 chars. Leave blank if title is self-explanatory.

Format the response *exactly* as:
Title: <commit title>
Description: <description>

Git diff:
%s
]], diff_content)

    -- *** MODIFIED: Prepare Gemini JSON Payload ***
    -- Escape the prompt text for JSON embedding
    local escaped_prompt_for_json = vim.fn.json_encode(prompt_text)
    if not escaped_prompt_for_json then
         vim.notify("Failed to JSON encode the prompt text.", vim.log.levels.ERROR)
         return currentTitle, nil
    end

    -- Construct the Gemini JSON payload
    -- Note the structure: { "contents": [{ "parts": [{"text": "..."}] }] }
    local json_payload = string.format(
        '{"contents": [{"parts":[{"text": %s}]}]}',
        escaped_prompt_for_json
    )

    -- *** MODIFIED: Prepare Gemini Curl Command ***
    -- Construct the Gemini API URL with the key
    local api_url = string.format(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=%s",
        api_key
    )

    -- Escape the URL and payload for the shell command
    local escaped_api_url = vim.fn.shellescape(api_url)
    -- Use single quotes around the payload data '-d' argument for robustness
    local escaped_json_payload = vim.fn.shellescape(json_payload) -- Already JSON, but shellescape handles potential shell metachars

    -- Construct the curl command using single quotes for the payload
    local curl_command = string.format(
        "curl -s -X POST %s -H 'Content-Type: application/json' -d %s",
        escaped_api_url,
        escaped_json_payload -- Use the shell-escaped payload
    )

    vim.notify("Requesting AI commit message from Gemini...", vim.log.levels.INFO)
    -- Optional: Debug print the command BEFORE executing (remove API key if logging publicly)
    -- print("DEBUG: Gemini Curl Command:", curl_command)

    -- Execute curl command (silently, handle errors below)
    local success_curl, response_lines, exit_code_curl = execute_command(curl_command, true, true)

    if not success_curl then
        vim.notify("Gemini API call failed (curl exit code: " .. exit_code_curl .. ").", vim.log.levels.ERROR)
        -- Attempt to parse response even on failure, might contain API error message
        if #response_lines > 0 then
            local response_text = table.concat(response_lines, "")
            local success_decode, decoded = pcall(vim.json.decode, response_text)
            if success_decode and decoded and decoded.error then
                local api_error = decoded.error.message or vim.inspect(decoded.error)
                vim.notify("Gemini API Error: " .. api_error, vim.log.levels.ERROR)
            else
                vim.notify("Raw Gemini API Response/Error: " .. response_text, vim.log.levels.WARN)
            end
        end
        return currentTitle, nil
    end

    local response_text = table.concat(response_lines, "")
    -- vim.notify("DEBUG Raw Response: " .. response_text, vim.log.levels.DEBUG) -- Keep for debugging

    local success_decode, decoded = pcall(vim.json.decode, response_text)
    if not success_decode then
        vim.notify("Failed to parse Gemini API response JSON: " .. response_text, vim.log.levels.ERROR)
        return currentTitle, nil
    end

    -- *** MODIFIED: Extract content from Gemini response structure ***
    -- Check for API-level errors in the JSON response (Gemini format)
    if decoded.error then
        local api_error = decoded.error.message or vim.inspect(decoded.error)
        vim.notify("Gemini API returned an error: " .. api_error, vim.log.levels.ERROR)
        return currentTitle, nil
    end

    -- Extract generated text from candidates -> content -> parts -> text
    local content = nil
    if decoded.candidates and type(decoded.candidates) == 'table' and #decoded.candidates > 0 then
        local candidate = decoded.candidates[1] -- Use the first candidate
        if candidate.content and candidate.content.parts and type(candidate.content.parts) == 'table' and #candidate.content.parts > 0 then
           content = candidate.content.parts[1].text
        end
    end

    if not content then
        vim.notify("Invalid Gemini API response format or empty content: " .. vim.inspect(decoded), vim.log.levels.ERROR)
        return currentTitle, nil
    end

    -- *** SAME PARSING LOGIC (relies on AI following "Title:/Description:" format) ***
    -- Parse title and description more robustly from the AI's *text* response
    local title = content:match("^[Tt]itle:%s*(.-)\n")
    local description = content:match("\n[Dd]escription:%s*(.*)") -- Match rest of string after Description:

    -- Trim whitespace
    title = title and title:match("^%s*(.-)%s*$")
    description = description and description:match("^%s*(.-)%s*$")

    if not title or title == "" then
        vim.notify("AI response parsed, but no valid 'Title:' field found. Using placeholder.", vim.log.levels.WARN)
        title = currentTitle -- Or maybe "AI Suggestion Failed"
    else
        -- Ensure title length is within limits
        if #title > 50 then
            title = string.sub(title, 1, 47) .. "..."
            vim.notify("AI title truncated to 50 characters.", vim.log.levels.WARN)
        end
    end

    if not description or description == "" then
        vim.notify("AI Description field not found or empty.", vim.log.levels.INFO)
        description = nil -- Explicitly set to nil
    else
        -- Optional: Truncate description if needed
        -- if #description > 500 then description = description:sub(1, 497) .. "..." end
    end

    vim.notify("AI message generated by Gemini.", vim.log.levels.INFO)
    return title, description
end


-- Command: GitAddAndCommitAll
vim.api.nvim_create_user_command("GitAddAndCommitAll",
    function()
        -- 1. Stage all changes FIRST - required by the command name "All"
        vim.notify("Staging all changes (git add .)...", vim.log.levels.INFO)
        local success_add, _, exit_code_add = execute_command("git add .", false, false) -- Don't silence errors here

        if not success_add and exit_code_add ~= 1 then                                   -- Fail on any error except 'nothing to add'
            vim.notify("Failed to stage changes (git add .). Aborting.", vim.log.levels.ERROR)
            return
        end
        if exit_code_add == 1 then
            vim.notify("No new changes detected to stage.", vim.log.levels.WARN)
            -- Check if *anything* is staged before proceeding
            local success_status, status_lines, _ = execute_command("git status --porcelain", true, true)
            local has_staged = false
            if success_status then
                for _, line in ipairs(status_lines) do
                    if line:match("^[MARCD]") then
                        has_staged = true; break;
                    end
                end
            end
            if not has_staged then
                vim.notify("No changes staged. Nothing to commit.", vim.log.levels.WARN)
                return -- Exit early
            end
            vim.notify("Proceeding with already staged changes.", vim.log.levels.INFO)
        else
            vim.notify("All changes staged successfully.", vim.log.levels.INFO)
        end


        -- 2. Prepare for commit message input
        local buf, win = create_centered_floating_window("Commit Message (type 'ai' for suggestion)", 3) -- Start with height 3
        local commit_message = "" -- Will hold the final full message (title + desc)
        local final_title = "" -- Will hold just the title part

        local close_prompt_window = function()
            if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
            end
        end

        -- Automatically close if buffer is left (e.g., user switches window)
        vim.api.nvim_create_autocmd("BufLeave", {
            buffer = buf,
            once = true,
            callback = function()
                vim.schedule(function()
                    close_prompt_window()
                    if commit_message == "" then -- Only notify if commit wasn't finalized
                        vim.notify("Commit cancelled (window left)", vim.log.levels.WARN)
                    end
                end)
            end,
        })

        -- Add escape key mapping to cancel in Insert mode
        vim.keymap.set("i", "<esc>", function()
            close_prompt_window()
            if commit_message == "" then
                vim.notify("Commit cancelled (Esc)", vim.log.levels.WARN)
            end
        end, { buffer = buf, nowait = true })
        -- Also allow Esc in Normal mode within the prompt window
        vim.keymap.set("n", "<esc>", function()
            close_prompt_window()
            if commit_message == "" then
                vim.notify("Commit cancelled (Esc)", vim.log.levels.WARN)
            end
        end, { buffer = buf, nowait = true, silent = true })


        -- Set up the prompt callback (called when user presses Enter)
        vim.fn.prompt_setcallback(buf, function(input)
            close_prompt_window() -- Close window immediately

            if not input or input == "" then
                vim.notify("Commit cancelled (empty message)", vim.log.levels.WARN)
                return
            end

            local final_description = nil
            -- Default to user input unless 'ai' is specified
            local is_ai_request = (input:lower() == "ai")

            -- Handle AI generation request
            if is_ai_request then
                -- AI function requires changes to be staged (we did that above)
                local ai_title, ai_description = get_ai_title_and_description("AI Suggestion Failed") -- Call the updated function

                if ai_title and ai_title ~= "AI Suggestion Failed" then
                    final_title = ai_title
                    final_description = ai_description -- Can be nil
                    vim.notify("Using AI generated message from Gemini.", vim.log.levels.INFO)
                else
                    vim.notify("Failed to generate Gemini commit message or no staged changes found. Aborting.",
                        vim.log.levels.ERROR)
                    return
                end
            else
                -- Use user input directly. Assume first line is title, rest is description
                vim.notify("Using user-provided commit message.", vim.log.levels.INFO)
                local lines = vim.split(input, "\n", { trimempty = true })
                final_title = lines[1] or ""
                if #lines > 1 then
                    final_description = table.concat(lines, "\n", 2) -- Join lines starting from the second one
                end
            end

            -- Construct final commit message string
            commit_message = final_title
            if final_description and final_description ~= "" then
                -- Ensure a blank line between title and description
                commit_message = commit_message .. "\n\n" .. final_description
            end

            -- Escape the final commit message for the shell command using single quotes
            -- Replaced manual escaping with vim.fn.shellescape for robustness
            local escaped_commit_message_arg = vim.fn.shellescape(commit_message)

            -- Get current branch (ensure it's trimmed)
            local success_branch, branch_output, _ = execute_command("git branch --show-current", true, true)
            if not success_branch or #branch_output == 0 then
                vim.notify("Error: Could not determine the current branch. Aborting.", vim.log.levels.ERROR)
                return
            end
            local current_branch = branch_output[1]:match("^%s*(.-)%s*$")

            -- Execute git commit, pull, push sequence
            local commands = {
                -- Stage all was already done
                 -- Use -m for simple messages, use -F - for complex messages passed via stdin?
                 -- Using -m with shellescape should be fine for multiline messages.
                { cmd = string.format("git commit -m %s", escaped_commit_message_arg), msg = "Committing..." },
                { cmd = "git pull --no-edit",                                          msg = "Pulling changes..." },
            }

            for i, command in ipairs(commands) do
                vim.notify(command.msg, vim.log.levels.INFO)
                local success_cmd, output_lines_cmd, exit_code_cmd = execute_command(command.cmd, true, false) -- Show errors, get output
                if not success_cmd then
                    if i == 1 then -- Commit failed
                        vim.notify("Commit failed (exit code " .. exit_code_cmd .. "). Aborting.", vim.log.levels.ERROR)
                        vim.notify("Output:\n" .. table.concat(output_lines_cmd, "\n"), vim.log.levels.ERROR)
                    elseif i == 2 then -- Pull failed
                        vim.notify(
                            "Pull failed (exit code " .. exit_code_cmd .. "). Resolve conflicts and push manually.",
                            vim.log.levels.ERROR)
                         vim.notify("Output:\n" .. table.concat(output_lines_cmd, "\n"), vim.log.levels.ERROR)
                    else -- Should not happen with current commands
                        vim.notify("Command failed (exit code " .. exit_code_cmd .. "). Aborting.", vim.log.levels.ERROR)
                         vim.notify("Output:\n" .. table.concat(output_lines_cmd, "\n"), vim.log.levels.ERROR)
                    end
                    return -- Stop the sequence
                end
            end

            -- Check if branch exists on remote (use shellescape)
            local escaped_branch_for_check = vim.fn.shellescape(current_branch)
            vim.notify("Checking remote status for branch: " .. current_branch, vim.log.levels.INFO)
            local success_remote_check, remote_check_lines, _ = execute_command(
                "git ls-remote --heads origin " .. escaped_branch_for_check, true, true)
            local branch_exists_on_remote = success_remote_check and #remote_check_lines > 0

            local push_command
            if branch_exists_on_remote then
                push_command = "git push"
                vim.notify("Branch exists on remote. Pushing...", vim.log.levels.INFO)
            else
                push_command = "git push --set-upstream origin " .. escaped_branch_for_check
                vim.notify("Branch does not exist on remote. Pushing with --set-upstream...", vim.log.levels.INFO)
            end

            local success_push, push_output, push_exit_code = execute_command(push_command, true, false) -- Show errors, get output
            if success_push then
                vim.notify("Successfully committed and pushed.", vim.log.levels.INFO)
                vim.notify("Commit: " .. final_title, vim.log.levels.INFO) -- Show the title used
            else
                vim.notify("Push failed (exit code: " .. push_exit_code .. "). Please check git output or run 'git push' manually.", vim.log.levels.ERROR)
                vim.notify("Output:\n" .. table.concat(push_output, "\n"), vim.log.levels.ERROR)
            end
        end)

        -- Start prompt
        vim.fn.prompt_setprompt(buf, "Commit msg ('ai'?): ") -- Set prompt text
        vim.cmd("startinsert")                               -- Enter insert mode in the prompt buffer
    end,
    {} -- No arguments for the command
)
vim.keymap.set("n", "<leader>ca", "<cmd>GitAddAndCommitAll<CR>", { desc = "Git Add All, Commit, Pull, Push" })


-- Command: GitCheckoutNewBranch
vim.api.nvim_create_user_command("GitCheckoutNewBranch",
    function()
        vim.ui.input({ prompt = "New branch name: " }, function(input)
            if input and input ~= "" then
                local escaped_branch = vim.fn.shellescape(input)
                -- Use execute_command to run and handle potential errors
                vim.notify("Checking out new branch: " .. input, vim.log.levels.INFO)
                local success, output_lines, exit_code = execute_command("git checkout -b " .. escaped_branch, true, false) -- Show errors
                if success then
                    vim.notify("Checked out new branch: " .. input, vim.log.levels.INFO)
                else
                    vim.notify("Failed to checkout new branch (exit code: " .. exit_code .. "): " .. input, vim.log.levels.ERROR)
                    vim.notify("Output:\n" .. table.concat(output_lines, "\n"), vim.log.levels.ERROR)
                end
            else
                vim.notify("Branch checkout cancelled", vim.log.levels.WARN)
            end
        end)
    end,
    {})
vim.keymap.set("n", "<leader>co", "<cmd>GitCheckoutNewBranch<CR>", { desc = "Git Checkout New Branch" })


-- Keymap: Git Pull
vim.keymap.set("n", "<leader>gp", function()
    vim.notify("Pulling changes (git pull --no-edit)...", vim.log.levels.INFO)
    local success, output_lines, exit_code = execute_command("git pull --no-edit", true, false) -- Show errors, get output
    if success then
        vim.notify("Pull successful.", vim.log.levels.INFO)
    else
        vim.notify("Pull failed (exit code: " .. exit_code .. "). Check git output or resolve conflicts.", vim.log.levels.ERROR)
        vim.notify("Output:\n" .. table.concat(output_lines, "\n"), vim.log.levels.ERROR)
    end
end, { desc = "Git Pull" })


-- Command: GitPushCurrentBranch (Handles upstream)
vim.api.nvim_create_user_command("GitPushCurrentBranch",
    function()
        -- Get current branch
        local success_branch, branch_output, _ = execute_command("git branch --show-current", true, true)
        if not success_branch or #branch_output == 0 then
            vim.notify("Error: Could not determine the current branch.", vim.log.levels.ERROR)
            return
        end
        local current_branch = branch_output[1]:match("^%s*(.-)%s*$")
        local escaped_branch = vim.fn.shellescape(current_branch)

        -- Check if branch exists on remote
        vim.notify("Checking remote status for branch: " .. current_branch, vim.log.levels.INFO)
        local success_remote_check, remote_check_lines, _ = execute_command(
            "git ls-remote --heads origin " .. escaped_branch, true, true)
        local branch_exists_on_remote = success_remote_check and #remote_check_lines > 0

        local push_command
        if branch_exists_on_remote then
            push_command = "git push"
            vim.notify("Pushing current branch (" .. current_branch .. ") ...", vim.log.levels.INFO)
        else
            push_command = "git push --set-upstream origin " .. escaped_branch
            vim.notify("Pushing current branch (" .. current_branch .. ") with --set-upstream...", vim.log.levels.INFO)
        end

        local success_push, output_lines, exit_code = execute_command(push_command, true, false) -- Show errors, get output
        if success_push then
            vim.notify("Push successful.", vim.log.levels.INFO)
        else
            vim.notify("Push failed (exit code: " .. exit_code .. "). Check git output.", vim.log.levels.ERROR)
            vim.notify("Output:\n" .. table.concat(output_lines, "\n"), vim.log.levels.ERROR)
        end
    end,
    {})


print("Git helper commands loaded (with Gemini AI commit).") -- Confirmation message
