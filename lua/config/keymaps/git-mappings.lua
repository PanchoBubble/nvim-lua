vim.keymap.set("n", "<leader>ca", "<cmd>GitAddAndCommitAll<CR>")

vim.api.nvim_create_user_command("GitAddAndCommitAll",
    function()
        -- Use vim.ui.input to prompt the user
        vim.ui.input({ prompt = "Commit message: " }, function(input)
            if input then
                local current_branch = vim.fn.systemlist("git branch --show-current")
                    [1] -- Get current branch name
                if not current_branch then
                    print("Error: Could not determine the current branch")
                    return
                end

                -- Add, commit, and attempt to pull and push
                vim.cmd("Git add .")
                vim.cmd("Git commit -m '" .. input .. "'")
                vim.cmd("Git pull --no-edit")

                -- Check if the branch exists on the remote
                local remote_branch_exists = vim.fn.systemlist("Git ls-remote --heads origin " .. current_branch)

                if #remote_branch_exists == 0 then
                    -- Branch does not exist on the remote, push with --set-upstream
                    vim.cmd("!git push --set-upstream origin " .. current_branch)
                else
                    -- Branch exists, normal push
                    vim.cmd("Git push")
                end

                vim.print("Committed and pushed. Commit message: " .. input)
            else
                print("Prompt cancelled")
            end
        end)
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
