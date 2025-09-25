local M = {}

-- HTML export utilities for markdown generation
local highlight_capture = require('personal.highlight-capture')

-- Configuration
M.config = {
  preview_width = 1200,
  preview_height = 800,
  sample_lines = 20,
  supported_languages = {
    'lua', 'javascript', 'typescript', 'tsx', 'python', 'go', 'rust',
    'bash', 'json', 'yaml', 'markdown', 'html', 'css', 'sql'
  }
}

function M.setup(opts)
  M.config = vim.tbl_extend('force', M.config, opts or {})
  highlight_capture.setup()
end

-- Generate sample code for a specific language
local function get_language_sample(language)
  local samples = {}
  
  samples.lua = [[local function fibonacci(n)
  if n <= 1 then
    return n
  end
  return fibonacci(n - 1) + fibonacci(n - 2)
end

-- Example usage
local result = fibonacci(10)
print("Result: " .. result)]]
    
  samples.javascript = [[const fetchUserData = async (userId) => {
  try {
    const response = await fetch(`/api/users/${userId}`);
    const userData = await response.json();
    return userData;
  } catch (error) {
    console.error('Failed to fetch user:', error);
    throw error;
  }
};]]

  samples.typescript = [[interface User {
  id: number;
  name: string;
  email: string;
  roles: Role[];
}

class UserService {
  private users: Map<number, User> = new Map();

  async getUser(id: number): Promise<User | null> {
    return this.users.get(id) || null;
  }
}]]

  samples.python = [[from typing import List, Optional
import asyncio

class DataProcessor:
    def __init__(self, config):
        self.config = config
        self.results = []
    
    async def process_batch(self, items):
        """Process a batch of items asynchronously."""
        processed = []
        for item in items:
            result = await self._process_item(item)
            if result:
                processed.append(result)
        return processed if processed else None]]

  samples.go = [[package main

import (
    "context"
    "fmt"
    "log"
    "time"
)

type UserRepository interface {
    GetUser(ctx context.Context, id int64) (*User, error)
    CreateUser(ctx context.Context, user *User) error
}

func (s *Service) ProcessUsers(ctx context.Context) error {
    users, err := s.repo.GetAllUsers(ctx)
    if err != nil {
        return fmt.Errorf("failed to get users: %w", err)
    }
    
    for _, user := range users {
        if err := s.processUser(ctx, user); err != nil {
            log.Printf("Error processing user %d: %v", user.ID, err)
        }
    }
    return nil
}]]

  samples.rust = [[use std::collections::HashMap;
use tokio::sync::RwLock;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct User {
    pub id: u64,
    pub name: String,
    pub email: String,
}

pub struct UserCache {
    cache: RwLock<HashMap<u64, User>>,
}

impl UserCache {
    pub async fn get_user(&self, id: u64) -> Option<User> {
        let cache = self.cache.read().await;
        cache.get(&id).cloned()
    }
}]]

  samples.bash = [[#!/bin/bash

# Deployment script with error handling
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly APP_NAME="myapp"
readonly DEPLOY_ENV="${1:-staging}"

deploy_application() {
    local env="$1"
    
    echo "Deploying $APP_NAME to $env..."
    
    if [ ! -f "$SCRIPT_DIR/config/$env.env" ]; then
        echo "Error: Config file for $env not found" >&2
        return 1
    fi
    
    source "$SCRIPT_DIR/config/$env.env"
    
    # Build and deploy  
    docker build -t "$APP_NAME:$env" .
    docker-compose -f "docker-compose.$env.yml" up -d
}

deploy_application "$DEPLOY_ENV"]]

  samples.json = [[{
  "name": "modern-app",
  "version": "1.0.0",
  "description": "A modern application with TypeScript and React",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "test": "jest --watch",
    "test:ci": "jest --ci --coverage"
  },
  "dependencies": {
    "react": "^18.2.0",
    "next": "^13.0.0",
    "@types/react": "^18.0.0"
  },
  "devDependencies": {
    "typescript": "^4.9.0",
    "jest": "^29.0.0",
    "@testing-library/react": "^13.0.0"
  }
}]]
  
  return samples[language] or "# No sample available for " .. language
end

-- Create a temporary buffer with sample code
local function create_temp_buffer(language, sample_code)
  local bufnr = vim.api.nvim_create_buf(false, true)
  
  -- Set filetype to enable syntax highlighting
  vim.api.nvim_buf_set_option(bufnr, 'filetype', language)
  
  -- Set the content
  local lines = vim.split(sample_code:gsub('\n$', ''), '\n')
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  
  -- Ensure treesitter is loaded for this filetype
  vim.treesitter.start(bufnr)
  
  return bufnr
end

-- Generate HTML preview for a specific language
function M.generate_language_preview(language, output_name)
  output_name = output_name or language .. '_sample'
  
  -- Get sample code
  local sample_code = get_language_sample(language)
  
  -- Create temporary buffer
  local bufnr = create_temp_buffer(language, sample_code)
  
  -- Generate HTML
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local end_line = math.min(line_count, M.config.sample_lines)
  
  local html_file = highlight_capture.capture_range(1, end_line, output_name, { show_line_numbers = true })
  
  -- Clean up temporary buffer
  vim.api.nvim_buf_delete(bufnr, { force = true })
  
  return html_file
end

-- Generate previews for all supported languages
function M.generate_all_previews()
  local results = {}
  
  vim.notify("Generating syntax highlighting previews...", vim.log.levels.INFO)
  
  for _, language in ipairs(M.config.supported_languages) do
    local html_file = M.generate_language_preview(language)
    if html_file then
      results[language] = html_file
      vim.notify("Generated preview for " .. language, vim.log.levels.INFO)
    else
      vim.notify("Failed to generate preview for " .. language, vim.log.levels.WARN)
    end
  end
  
  return results
end

-- Generate markdown section with all language previews
function M.generate_preview_markdown()
  local previews = M.generate_all_previews()
  local markdown_lines = {
    "## 🎨 Syntax Highlighting Previews",
    "",
    "This section showcases how different programming languages appear with the current colorscheme.",
    ""
  }
  
  for _, language in ipairs(M.config.supported_languages) do
    local html_file = previews[language]
    if html_file then
      local relative_path = html_file:gsub(vim.fn.expand("~/.config/nvim/"), "")
      table.insert(markdown_lines, string.format("### %s", language:gsub("^%l", string.upper)))
      table.insert(markdown_lines, "")
      table.insert(markdown_lines, string.format("![%s syntax highlighting](%s)", language, relative_path))
      table.insert(markdown_lines, "")
    end
  end
  
  return table.concat(markdown_lines, '\n')
end

-- Create a color palette preview
function M.generate_color_palette()
  local colors = highlight_capture.get_colorscheme_info()
  local important_groups = {
    'Normal', 'Comment', 'Keyword', 'String', 'Number', 'Function',
    'Variable', 'Type', 'Constant', 'Statement', 'PreProc', 'Special'
  }
  
  local html_content = [[
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { 
      font-family: 'JetBrains Mono', monospace; 
      margin: 20px; 
      background: ]] .. highlight_capture.get_bg_color() .. [[;
      color: ]] .. highlight_capture.get_fg_color() .. [[;
    }
    .palette { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; }
    .color-group { 
      border: 1px solid #444; 
      border-radius: 8px; 
      padding: 16px; 
      background: rgba(255,255,255,0.05);
    }
    .color-swatch { 
      display: inline-block; 
      width: 20px; 
      height: 20px; 
      border-radius: 4px; 
      margin-right: 8px; 
      border: 1px solid #666;
    }
    .group-name { font-weight: bold; margin-bottom: 8px; }
  </style>
</head>
<body>
  <h2>Color Palette</h2>
  <div class="palette">
]]
  
  for _, group in ipairs(important_groups) do
    local color_info = colors['@' .. group] or colors[group]
    if color_info and (color_info.fg or color_info.bg) then
      html_content = html_content .. string.format([[
    <div class="color-group">
      <div class="group-name">%s</div>
      <div>
        <span class="color-swatch" style="background: %s;"></span>
        <code>%s</code>
      </div>
    </div>
]], group, color_info.fg or '#000000', color_info.fg or 'default')
    end
  end
  
  html_content = html_content .. [[
  </div>
</body>
</html>
]]
  
  local palette_file = highlight_capture.config.output_dir .. 'color_palette.html'
  local file = io.open(palette_file, 'w')
  if file then
    file:write(html_content)
    file:close()
    return palette_file
  end
  
  return nil
end

return M
