local M = {}

local html_export = require "personal.html-export"
local highlight_capture = require "personal.highlight-capture"

-- Configuration
M.config = {
  readme_path = vim.fn.expand "~/.config/nvim/README.md",
  backup_path = vim.fn.expand "~/.config/nvim/README.md.backup",
  preview_section_marker = "<!-- SYNTAX_PREVIEWS -->",
  preview_section_end = "<!-- END_SYNTAX_PREVIEWS -->",
  auto_backup = true,
  include_palette = true,
}

function M.setup(opts)
  M.config = vim.tbl_extend("force", M.config, opts or {})
  html_export.setup()
  highlight_capture.setup()
end

-- Read README content
local function read_readme()
  local file = io.open(M.config.readme_path, "r")
  if not file then
    vim.notify("README.md not found at " .. M.config.readme_path, vim.log.levels.ERROR)
    return nil
  end

  local content = file:read "*all"
  file:close()
  return content
end

-- Write README content
local function write_readme(content)
  local file = io.open(M.config.readme_path, "w")
  if not file then
    vim.notify("Failed to write README.md", vim.log.levels.ERROR)
    return false
  end

  file:write(content)
  file:close()
  return true
end

-- Create backup of README
local function create_backup()
  if not M.config.auto_backup then
    return true
  end

  local content = read_readme()
  if not content then
    return false
  end

  local backup_file = io.open(M.config.backup_path, "w")
  if not backup_file then
    vim.notify("Failed to create backup", vim.log.levels.WARN)
    return false
  end

  backup_file:write(content)
  backup_file:close()
  vim.notify("Created backup at " .. M.config.backup_path)
  return true
end

-- Generate the preview section content
local function generate_preview_section()
  local lines = {
    "",
    "## 🎨 Syntax Highlighting Showcase",
    "",
    "This section demonstrates how different programming languages appear with the current Neovim colorscheme and Tree-sitter highlighting.",
    "",
  }

  -- Generate language previews
  vim.notify("Generating language previews...", vim.log.levels.INFO)
  local previews = html_export.generate_all_previews()

  -- Group languages for better organization
  local language_groups = {
    {
      title = "Web Development",
      languages = { "html", "css", "javascript", "typescript", "tsx", "json" },
    },
    {
      title = "Backend & Systems",
      languages = { "lua", "python", "go", "rust", "bash" },
    },
    {
      title = "Data & Config",
      languages = { "sql", "yaml", "toml", "markdown" },
    },
  }

  for _, group in ipairs(language_groups) do
    table.insert(lines, "### " .. group.title)
    table.insert(lines, "")

    for _, language in ipairs(group.languages) do
      local html_file = previews[language]
      if html_file then
        local relative_path = html_file:gsub(vim.fn.expand "~/.config/nvim/", "")
        local lang_display = language:gsub("^%l", string.upper)

        -- Add collapsible details for cleaner README
        table.insert(lines, string.format "<details>")
        table.insert(
          lines,
          string.format("<summary><strong>%s</strong> - Click to view syntax highlighting</summary>", lang_display)
        )
        table.insert(lines, "")
        table.insert(lines, string.format("![%s syntax highlighting](%s)", lang_display, relative_path))
        table.insert(lines, "</details>")
        table.insert(lines, "")
      end
    end
  end

  -- Add color palette if enabled
  if M.config.include_palette then
    table.insert(lines, "### Color Palette")
    table.insert(lines, "")
    table.insert(lines, "Current colorscheme color groups:")
    table.insert(lines, "")

    local palette_file = html_export.generate_color_palette()
    if palette_file then
      local relative_path = palette_file:gsub(vim.fn.expand "~/.config/nvim/", "")
      table.insert(lines, string.format("![Color Palette](%s)", relative_path))
      table.insert(lines, "")
    end
  end

  -- Add generation timestamp and info
  table.insert(lines, "---")
  table.insert(lines, "")
  table.insert(lines, string.format("*Generated on %s using Tree-sitter highlighting*", os.date "%Y-%m-%d %H:%M:%S"))
  table.insert(lines, "")

  return table.concat(lines, "\n")
end

-- Update README with syntax previews
function M.update_readme_with_previews()
  -- Create backup
  if not create_backup() then
    vim.notify("Failed to create backup, aborting", vim.log.levels.ERROR)
    return false
  end

  -- Read current README
  local content = read_readme()
  if not content then
    return false
  end

  -- Generate new preview section
  vim.notify("Generating syntax highlighting previews...", vim.log.levels.INFO)
  local preview_section = generate_preview_section()

  -- Find existing preview section markers
  local start_marker = M.config.preview_section_marker
  local end_marker = M.config.preview_section_end

  local start_pos = content:find(start_marker, 1, true)
  local end_pos = content:find(end_marker, 1, true)

  local new_content
  if start_pos and end_pos then
    -- Replace existing section
    local before = content:sub(1, start_pos + #start_marker - 1)
    local after = content:sub(end_pos)
    new_content = before .. preview_section .. after
    vim.notify("Updated existing syntax preview section", vim.log.levels.INFO)
  else
    -- Add new section at the end
    local section_content = string.format("\n%s%s%s\n", start_marker, preview_section, end_marker)
    new_content = content .. section_content
    vim.notify("Added new syntax preview section to README", vim.log.levels.INFO)
  end

  -- Write updated README
  if write_readme(new_content) then
    vim.notify("Successfully updated README.md with syntax previews!", vim.log.levels.INFO)
    return true
  else
    return false
  end
end

-- Generate a single language preview for testing
function M.test_language_preview(language)
  language = language or "lua"

  vim.notify("Generating test preview for " .. language, vim.log.levels.INFO)
  local html_file = html_export.generate_language_preview(language, language .. "_test")

  if html_file then
    vim.notify("Generated test preview: " .. html_file, vim.log.levels.INFO)
    return html_file
  else
    vim.notify("Failed to generate test preview", vim.log.levels.ERROR)
    return nil
  end
end

return M
