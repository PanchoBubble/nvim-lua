--- Trouble
local trouble = require("trouble")
local function troubleMaker(action)
    trouble.toggle(action)
end
vim.keymap.set("n", "<leader>xx", troubleMaker)
vim.keymap.set("n", "<leader>xw", function() troubleMaker("workspace_diagnostics") end)
vim.keymap.set("n", "<leader>xd", function() troubleMaker("document_diagnostics") end)
vim.keymap.set("n", "<leader>xq", function() troubleMaker("quickfix") end)
vim.keymap.set("n", "<leader>xl", function() troubleMaker("loclist") end)
vim.keymap.set("n", "gR", function() troubleMaker("lsp_references") end)
