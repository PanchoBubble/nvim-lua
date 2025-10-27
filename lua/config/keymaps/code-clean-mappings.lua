vim.keymap.set("n", "<leader>qf", "<cmd>lua vim.lsp.buf.code_action()<CR>")

local function prettify()
  local filetype = vim.bo.filetype
  
  -- Use conform for supported file types with LSP fallback
  local conform_files = { 
    "typescript", "javascript", "typescriptreact", "javascriptreact", 
    "scss", "css", "html", "json", "yaml", "markdown" 
  }

  if vim.tbl_contains(conform_files, filetype) then
    require("conform").format({
      lsp_fallback = true,
      async = false,
      timeout_ms = 1000,
    })
    return
  end

  -- For other file types, try LSP formatting first
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local has_formatter = false
  
  for _, client in ipairs(clients) do
    if client.server_capabilities.documentFormattingProvider then
      has_formatter = true
      break
    end
  end

  if has_formatter then
    vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
  elseif vim.fn.exists(":EslintFixAll") > 0 and (filetype == "typescript" or filetype == "javascript" or filetype == "typescriptreact" or filetype == "javascriptreact") then
    vim.cmd("EslintFixAll")
  else
    vim.notify("No formatter available for " .. filetype, vim.log.levels.WARN)
  end
end
vim.keymap.set("n", "<leader><leader>", prettify)

-- Blammer
vim.keymap.set("n", "<leader>go", "<cmd>GitBlameOpenCommitURL<cr>")
-- Beautify
vim.keymap.set("n", "<leader>bf", "<cmd>%!js-beautify<cr>")
