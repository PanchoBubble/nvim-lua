vim.keymap.set("n", "<leader>qf", "<cmd>lua vim.lsp.buf.code_action()<CR>")

local function prettify()
  local filetype = vim.bo.filetype
  
  -- Use conform.nvim exclusively for web languages, no LSP fallback to prevent conflicts
  local conform_files = { 
    "typescript", "javascript", "typescriptreact", "javascriptreact", 
    "scss", "css", "html", "json", "yaml", "markdown" 
  }

  if vim.tbl_contains(conform_files, filetype) then
    require("conform").format({
      async = true,
      timeout_ms = 2000,
      lsp_fallback = false,  -- Disable lsp_fallback to prevent conflicts
    })
    return
  end

  -- For other file types, use LSP formatting only
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local has_formatter = false
  
  for _, client in ipairs(clients) do
    if client.server_capabilities.documentFormattingProvider then
      has_formatter = true
      break
    end
  end

  if has_formatter then
    vim.lsp.buf.format({ async = true, timeout_ms = 2000 })
  else
    vim.notify("No formatter available for " .. filetype, vim.log.levels.WARN)
  end
end
vim.keymap.set("n", "<leader><leader>", prettify)

-- Blammer
vim.keymap.set("n", "<leader>go", "<cmd>GitBlameOpenCommitURL<cr>")
-- Beautify
vim.keymap.set("n", "<leader>bf", "<cmd>%!js-beautify<cr>")
