-- LSP and formatting debug utilities

local M = {}

-- Check LSP attachment and capabilities for current buffer
function M.check_lsp_status()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[buf].filetype
  local filename = vim.api.nvim_buf_get_name(buf)
  
  print("=== LSP Debug Info ===")
  print("File: " .. filename)
  print("Filetype: " .. filetype)
  print("Buffer type: " .. vim.bo[buf].buftype)
  
  -- Check treesitter
  local ts_ok, ts_parsers = pcall(require, "nvim-treesitter.parsers")
  if ts_ok then
    local parser = ts_parsers.get_parser(buf)
    if parser then
      print("Treesitter parser: " .. parser:lang())
    else
      print("Treesitter parser: ❌ None found")
    end
  end
  print("")
  
  local clients = vim.lsp.get_clients({ bufnr = buf })
  
  if #clients == 0 then
    print("❌ No LSP clients attached to this buffer")
    return
  end
  
  print("📋 Attached LSP clients:")
  for _, client in ipairs(clients) do
    print("  • " .. client.name)
    
    local caps = client.server_capabilities
    print("    Formatting: " .. (caps.documentFormattingProvider and "✅" or "❌"))
    print("    Range Formatting: " .. (caps.documentRangeFormattingProvider and "✅" or "❌"))
    print("    Code Actions: " .. (caps.codeActionProvider and "✅" or "❌"))
    print("    Hover: " .. (caps.hoverProvider and "✅" or "❌"))
    print("    Completion: " .. (caps.completionProvider and "✅" or "❌"))
    print("    Go to Definition: " .. (caps.definitionProvider and "✅" or "❌"))
    print("    Go to Declaration: " .. (caps.declarationProvider and "✅" or "❌"))
    print("")
  end
end

-- Check formatting options for current buffer
function M.check_formatting_options()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[buf].filetype
  
  print("=== Formatting Debug Info ===")
  print("Filetype: " .. filetype)
  print("")
  
  -- Check conform.nvim formatters
  local conform_ok, conform = pcall(require, "conform")
  if conform_ok then
    local formatters = conform.list_formatters(buf)
    print("📝 Conform formatters:")
    if #formatters == 0 then
      print("  ❌ No conform formatters available")
    else
      for _, formatter in ipairs(formatters) do
        local status = formatter.available and "✅" or "❌"
        print("  " .. status .. " " .. formatter.name)
      end
    end
    
    -- Check if lsp_fallback is enabled (potential conflict source)
    local format_opts = conform.resolve_format_opts({ bufnr = buf })
    if format_opts.lsp_fallback then
      print("  ⚠️  LSP fallback is ENABLED - potential conflicts!")
    else
      print("  ✅ LSP fallback is DISABLED - conflict-free")
    end
    print("")
  else
    print("❌ conform.nvim not available")
    print("")
  end
  
  -- Check LSP formatting
  local clients = vim.lsp.get_clients({ bufnr = buf })
  local lsp_formatters = {}
  local formatting_conflicts = {}
  
  for _, client in ipairs(clients) do
    if client.server_capabilities.documentFormattingProvider then
      table.insert(lsp_formatters, client.name)
      -- Check for potential conflicts
      if conform_ok and #conform.list_formatters(buf) > 0 then
        table.insert(formatting_conflicts, client.name .. " (LSP) + conform.nvim")
      end
    end
  end
  
  print("🔧 LSP formatters:")
  if #lsp_formatters == 0 then
    print("  ✅ No LSP formatters available (good for conflict prevention)")
  else
    for _, name in ipairs(lsp_formatters) do
      print("  ⚠️  " .. name .. " (enabled - may cause conflicts)")
    end
  end
  print("")
  
  -- Conflict detection
  if #formatting_conflicts > 0 then
    print("🚨 POTENTIAL CONFLICTS DETECTED:")
    for _, conflict in ipairs(formatting_conflicts) do
      print("  ❌ " .. conflict)
    end
    print("  💡 Recommendation: Disable LSP formatting for this filetype")
  else
    print("✅ No formatting conflicts detected")
  end
  print("")
end

-- Test formatting with detailed output
function M.test_formatting()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[buf].filetype
  
  print("=== Testing Formatting ===")
  print("Filetype: " .. filetype)
  print("")
  
  -- Test conform formatting
  local conform_ok, conform = pcall(require, "conform")
  if conform_ok then
    print("🧪 Testing conform.nvim formatting...")
    local success, result = pcall(function()
      return conform.format({
        bufnr = buf,
        lsp_fallback = true,
        dry_run = true,
      })
    end)
    
    if success then
      print("  ✅ Conform formatting would succeed")
      if result then
        print("  📄 Formatters that would run: " .. vim.inspect(result))
      end
    else
      print("  ❌ Conform formatting failed: " .. tostring(result))
    end
    print("")
  end
  
  -- Test LSP formatting
  local clients = vim.lsp.get_clients({ bufnr = buf })
  for _, client in ipairs(clients) do
    if client.server_capabilities.documentFormattingProvider then
      print("🧪 Testing LSP formatting with " .. client.name .. "...")
      local success, result = pcall(function()
        return vim.lsp.buf.format({
          bufnr = buf,
          name = client.name,
          async = false,
          timeout_ms = 1000,
        })
      end)
      
      if success then
        print("  ✅ LSP formatting with " .. client.name .. " succeeded")
      else
        print("  ❌ LSP formatting with " .. client.name .. " failed: " .. tostring(result))
      end
    end
  end
  print("")
end

-- Test what's under cursor for LSP
function M.test_cursor_word()
  local word = vim.fn.expand("<cword>")
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local buf = vim.api.nvim_get_current_buf()
  
  print("=== Cursor Debug Info ===")
  print("Word under cursor: '" .. word .. "'")
  print("Cursor position: line " .. cursor_pos[1] .. ", col " .. cursor_pos[2])
  
  -- Test LSP hover at cursor
  print("\n🔍 Testing LSP hover...")
  local params = vim.lsp.util.make_position_params()
  local clients = vim.lsp.get_clients({ bufnr = buf })
  
  for _, client in ipairs(clients) do
    if client.server_capabilities.hoverProvider then
      print("Requesting hover from " .. client.name .. "...")
      client.request("textDocument/hover", params, function(err, result)
        if err then
          print("❌ Hover error from " .. client.name .. ": " .. vim.inspect(err))
        elseif result and result.contents then
          print("✅ Hover success from " .. client.name)
        else
          print("⚠️  No hover result from " .. client.name)
        end
      end)
    end
  end
end

-- Test formatting performance and detect timing issues
function M.test_formatting_performance()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[buf].filetype
  
  print("=== Formatting Performance Test ===")
  print("Filetype: " .. filetype)
  print("")
  
  -- Test conform formatting performance
  local conform_ok, conform = pcall(require, "conform")
  if conform_ok then
    local formatters = conform.list_formatters(buf)
    if #formatters > 0 then
      print("🧪 Testing conform.nvim performance...")
      local start_time = vim.loop.hrtime()
      
      local success, result = pcall(function()
        return conform.format({
          bufnr = buf,
          async = false,
          dry_run = true,
          timeout_ms = 5000,
          lsp_fallback = false,
        })
      end)
      
      local end_time = vim.loop.hrtime()
      local duration_ms = (end_time - start_time) / 1000000
      
      if success then
        print("  ✅ Conform formatting completed in " .. string.format("%.2f", duration_ms) .. "ms")
        if duration_ms > 2000 then
          print("  ⚠️  Slow formatting detected - consider using prettierd")
        elseif duration_ms > 5000 then
          print("  🚨 Very slow formatting - check formatter configuration")
        end
      else
        print("  ❌ Conform formatting failed: " .. tostring(result))
      end
      print("")
    end
  end
  
  -- Test character corruption detection
  print("🔍 Buffer integrity check...")
  local line_count = vim.api.nvim_buf_line_count(buf)
  local first_line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
  local last_line = vim.api.nvim_buf_get_lines(buf, -2, -1, false)[1] or ""
  
  print("  📊 Buffer stats:")
  print("    Lines: " .. line_count)
  print("    First line length: " .. #first_line)
  print("    Last line length: " .. #last_line)
  
  -- Check for common corruption signs
  if first_line:match("^%s*$") and line_count > 1 then
    print("  ⚠️  First line is empty/whitespace - potential indentation issue")
  end
  
  if first_line:find("\t") and vim.o.expandtab then
    print("  ⚠️  Tabs found with expandtab set - potential corruption source")
  end
  
  print("")
end

-- Setup user commands
function M.setup()
  vim.api.nvim_create_user_command("LspDebug", M.check_lsp_status, {
    desc = "Check LSP attachment and capabilities for current buffer"
  })
  
  vim.api.nvim_create_user_command("FormatDebug", M.check_formatting_options, {
    desc = "Check available formatters and detect conflicts"
  })
  
  vim.api.nvim_create_user_command("FormatTest", M.test_formatting, {
    desc = "Test formatting with detailed output"
  })
  
  vim.api.nvim_create_user_command("FormatPerf", M.test_formatting_performance, {
    desc = "Test formatting performance and detect timing issues"
  })
  
  vim.api.nvim_create_user_command("CursorDebug", M.test_cursor_word, {
    desc = "Test what LSP sees under the cursor"
  })
end

return M
