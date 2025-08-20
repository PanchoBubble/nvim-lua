# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a modern Neovim configuration using Lazy.nvim plugin manager with a modular Lua-based architecture. The configuration is optimized for TypeScript/React development with AI-powered coding assistance.

### Core Structure
- `init.lua` - Main entry point that bootstraps Lazy.nvim and loads all modules
- `lua/config/plugins/` - Individual plugin configurations (lazy-loaded)
- `lua/config/keymaps/` - Organized keymap modules by category
- `lua/config/options.lua` - Vim settings and options
- `lua/config/autocmds.lua` - Auto-commands
- `lua/personal/` - Custom utilities and Git integration

### Plugin Management
All plugins are managed through Lazy.nvim with lazy loading for performance. Plugin configurations are split into focused modules:
- `lsp.lua` - LSP setup with Mason, conform.nvim
- `completion.lua` - nvim-cmp with multiple sources
- `telescope.lua` - Fuzzy finder with FZF integration
- `avanti.lua` - AI coding assistant (Claude/Gemini)
- `super-maven.lua` - AI code completion

## Development Commands

### Code Formatting
- **StyluaLua formatting**: Uses `stylelua.toml` config (2 spaces, no call parentheses)
- **JavaScript/TypeScript**: Handled by conform.nvim with Prettier integration
- **ESLint**: Auto-formatting on save for .ts/.js files

### Key Mappings (Space as leader)
- `<C-p>` - Find files (Telescope)
- `<C-f>` - Live grep search
- `<leader>bb` - Buffer switcher
- `<leader>fb` - Find buffers
- `<leader>fw` - Find word under cursor
- `<leader>rn` - LSP rename
- `<leader>gb` - Custom Git branch switcher

### Custom Commands
- `:Branch` - Interactive Git branch switcher with floating window
- `:JsonFormat` - Format JSON using Python
- Standard LSP commands available through keymaps

## Custom Features

### Git Integration
- Custom branch switcher in `lua/personal/git/` with floating window interface
- Git blame integration via blammer plugin
- Status display and branch management utilities

### AI Integration
- Avante plugin for AI-powered coding (Claude/Gemini backends)
- SuperMaven for AI code completion
- Configured for TypeScript/React development workflows

## Configuration Patterns

### Adding New Plugins
1. Create new file in `lua/config/plugins/[plugin-name].lua`
2. Return plugin spec with lazy loading configuration
3. Plugin will be auto-loaded by Lazy.nvim

### Adding Keymaps
1. Add to appropriate file in `lua/config/keymaps/`
2. Import in `lua/config/keymaps/init.lua` if creating new category
3. Follow existing patterns for consistent organization

### LSP Configuration
LSP setup is in `lua/config/plugins/lsp.lua` using Mason for server management. New language servers should be added to the Mason ensure_installed list and configured in the lspconfig setup.