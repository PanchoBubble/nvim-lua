vim.keymap.set("n", "<C-x>", '<cmd>Noice dismiss<CR>')

vim.keymap.set("n", "<C-x>", '<cmd>Noice dismiss<CR>')

vim.api.nvim_create_user_command("PortKill",
    function()
        -- Use vim.ui.input to prompt the user
        vim.ui.input({ prompt = "Port number: " }, function(input)
            if input then
                local service = vim.fn.systemlist("lsof -i tcp:" .. input)[2]
                if service then
                    local pid = string.match(service, "^%S+%s+(%S+)")
                    vim.cmd("silent !kill " .. pid)
                    vim.print("Killed process with PID: " .. pid)
                else
                    vim.print("No process found with port number: " .. input)
                end
            end
        end)
    end,
    {}
)
