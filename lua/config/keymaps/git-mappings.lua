vim.keymap.set("n", "<leader>ca", "<cmd>GitAddAndCommitAll<CR>")

vim.api.nvim_create_user_command("GitAddAndCommitAll",
    function()
        -- Use vim.ui.input to prompt the user
        vim.ui.input({ prompt = "Commit message: " }, function(input)
            if input then
                vim.cmd("Git add .")
                vim.cmd("Git commit -m '" .. input .. "'")
                vim.cmd("Git pull --no-edit")
                vim.cmd("Git push")
                vim.print("Committed and pushed. Commit message: " .. input)
            else
                print("Prompt cancelled")
            end
        end)
    end,
    {})

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
