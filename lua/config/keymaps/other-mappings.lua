vim.keymap.set("n", "<C-x>", '<cmd>Noice dismiss<CR>')

-- Syntax Highlighting Preview Commands
vim.keymap.set("n", "<leader>shp", function()
  require('personal.highlight-capture').capture_buffer()
end, { desc = "Capture buffer syntax highlighting" })

vim.keymap.set("v", "<leader>shp", function()
  require('personal.highlight-capture').capture_selection()
end, { desc = "Capture selection syntax highlighting" })

vim.keymap.set("n", "<leader>sht", function()
  vim.ui.input({ prompt = "Language: " }, function(language)
    if language then
      require('personal.readme-generator').test_language_preview(language)
    end
  end)
end, { desc = "Test language preview generation" })

vim.keymap.set("n", "<leader>shr", function()
  require('personal.readme-generator').update_readme_with_previews()
end, { desc = "Update README with syntax previews" })

vim.keymap.set("n", "<leader>sha", function()
  require('personal.readme-generator').regenerate_all()
end, { desc = "Regenerate all syntax previews" })

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
