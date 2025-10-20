local M = {}

-- Configuration for highlight capture
M.config = {
  output_dir = vim.fn.expand "~/.config/nvim/images/syntax-previews/",
  temp_dir = "/tmp/nvim-highlights/",
  html_template = [[
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { 
      font-family: 'JetBrains Mono', 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace; 
      margin: 0; 
      padding: 20px; 
      background: %s;
      line-height: 1.4;
    }
    .code-block { 
      background: %s; 
      color: %s;
      padding: 20px; 
      border-radius: 8px; 
      overflow-x: auto; 
      border: 1px solid %s;
      font-size: 14px;
      white-space: pre;
    }
    .line-number {
      display: inline-block;
      width: 3em;
      text-align: right;
      margin-right: 1em;
      color: %s;
      user-select: none;
    }
  </style>
</head>
<body>
  <div class="code-block">%s</div>
</body>
</html>
]],
}

-- Setup function
function M.setup(opts)
  M.config = vim.tbl_extend("force", M.config, opts or {})

  -- Create output directories if they don't exist
  vim.fn.mkdir(M.config.output_dir, "p")
  vim.fn.mkdir(M.config.temp_dir, "p")
end

-- Get hex color from highlight group
local function get_hl_color(group_name, attr)
  local hl = vim.api.nvim_get_hl(0, { name = group_name })
  if hl and hl[attr] then
    return string.format("#%06x", hl[attr])
  end
  return nil
end

-- Get background color for normal text
local function get_bg_color()
  return get_hl_color("Normal", "bg") or "#1e1e1e"
end

-- Get foreground color for normal text
local function get_fg_color()
  return get_hl_color("Normal", "fg") or "#ffffff"
end

-- Get border color
local function get_border_color()
  return get_hl_color("WinSeparator", "fg") or get_hl_color("VertSplit", "fg") or "#444444"
end

-- Get line number color
local function get_line_number_color()
  return get_hl_color("LineNr", "fg") or "#666666"
end

-- Extract highlight information for a specific position
local function get_highlight_at_pos(bufnr, row, col)
  local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
  if not line or col > #line then
    return { name = "Normal" }
  end

  -- Get treesitter highlight at position
  local ts_hl = vim.treesitter.get_captures_at_pos(bufnr, row - 1, col - 1)
  if ts_hl and #ts_hl > 0 then
    -- Use the most specific (last) capture
    local capture = ts_hl[#ts_hl]
    local hl_name = "@" .. capture.capture .. "." .. (capture.lang or vim.bo[bufnr].filetype)
    return { name = hl_name }
  end

  -- Fallback to syntax highlighting
  local hl_id = vim.fn.synID(row, col, 1)
  local hl_name = vim.fn.synIDattr(hl_id, "name")
  return { name = hl_name ~= "" and hl_name or "Normal" }
end

-- Convert a single line to HTML with syntax highlighting
local function line_to_html(bufnr, line_content, line_number, show_line_numbers)
  local html_line = ""

  if show_line_numbers then
    local line_num_color = get_line_number_color()
    html_line = string.format('<span class="line-number" style="color: %s;">%3d</span>', line_num_color, line_number)
  end

  if #line_content == 0 then
    return html_line .. "\n"
  end

  local current_style = nil
  local current_span = ""

  for col = 1, #line_content do
    local char = line_content:sub(col, col)
    local hl_info = get_highlight_at_pos(bufnr, line_number, col)

    -- Get colors for this highlight group
    local fg_color = get_hl_color(hl_info.name, "fg") or get_fg_color()
    local bg_color = get_hl_color(hl_info.name, "bg")
    local bold = vim.api.nvim_get_hl(0, { name = hl_info.name }).bold
    local italic = vim.api.nvim_get_hl(0, { name = hl_info.name }).italic

    -- Create style string
    local style = string.format("color: %s", fg_color)
    if bg_color then
      style = style .. string.format("; background-color: %s", bg_color)
    end
    if bold then
      style = style .. "; font-weight: bold"
    end
    if italic then
      style = style .. "; font-style: italic"
    end

    -- If style changed, close previous span and start new one
    if style ~= current_style then
      if current_style then
        html_line = html_line .. "</span>"
      end
      html_line = html_line .. string.format('<span style="%s">', style)
      current_style = style
    end

    -- Escape HTML characters
    local escaped_char = char:gsub("[<>&]", {
      ["<"] = "&lt;",
      [">"] = "&gt;",
      ["&"] = "&amp;",
    })

    html_line = html_line .. escaped_char
  end

  -- Close final span
  if current_style then
    html_line = html_line .. "</span>"
  end

  return html_line .. "\n"
end

-- Export buffer range to HTML
function M.export_to_html(bufnr, start_line, end_line, output_file, opts)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  opts = opts or {}
  local show_line_numbers = opts.show_line_numbers ~= false

  -- Ensure treesitter is running for this buffer
  vim.treesitter.start(bufnr)

  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
  local html_lines = {}

  -- Process each line
  for i, line in ipairs(lines) do
    local line_number = start_line + i - 1
    local html_line = line_to_html(bufnr, line, line_number, show_line_numbers)
    table.insert(html_lines, html_line)
  end

  -- Get theme colors
  local bg_color = get_bg_color()
  local fg_color = get_fg_color()
  local border_color = get_border_color()
  local line_num_color = get_line_number_color()

  -- Generate complete HTML
  local html_content = string.format(
    M.config.html_template,
    bg_color,
    bg_color,
    fg_color,
    border_color,
    line_num_color,
    table.concat(html_lines, "")
  )

  -- Write to file
  local file = io.open(output_file, "w")
  if not file then
    vim.notify("Failed to create HTML file: " .. output_file, vim.log.levels.ERROR)
    return false
  end

  file:write(html_content)
  file:close()

  return true
end

-- Capture current selection as HTML
function M.capture_selection(output_name)
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"

  if start_pos[2] == 0 or end_pos[2] == 0 then
    vim.notify("No selection found", vim.log.levels.WARN)
    return nil
  end

  return M.capture_range(start_pos[2], end_pos[2], output_name or "selection")
end

-- Capture buffer range
function M.capture_range(start_line, end_line, output_name, opts)
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype

  -- Create output filename
  output_name = output_name or ("capture_" .. os.time())
  local html_file = M.config.output_dir .. output_name .. "_" .. filetype .. ".html"

  -- Generate HTML
  local success = M.export_to_html(bufnr, start_line, end_line, html_file, opts)

  if success then
    vim.notify("Generated: " .. html_file)
    return html_file
  else
    return nil
  end
end

-- Capture entire buffer
function M.capture_buffer(output_name)
  local bufnr = vim.api.nvim_get_current_buf()
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  return M.capture_range(1, line_count, output_name or "full_buffer")
end

-- Get all available highlight groups with their colors
function M.get_colorscheme_info()
  local colors = {}
  local highlight_groups = vim.fn.getcompletion("@", "highlight")

  for _, group in ipairs(highlight_groups) do
    local hl = vim.api.nvim_get_hl(0, { name = group })
    if hl.fg or hl.bg then
      colors[group] = {
        fg = hl.fg and string.format("#%06x", hl.fg) or nil,
        bg = hl.bg and string.format("#%06x", hl.bg) or nil,
        bold = hl.bold or false,
        italic = hl.italic or false,
      }
    end
  end

  return colors
end

return M
