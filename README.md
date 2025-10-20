# Modern Neovim Configuration

A comprehensive, AI-powered Neovim configuration optimized for TypeScript/React development with advanced Git workflows, featuring Lazy.nvim plugin management, modular Lua architecture, and extensive customization for modern development workflows.

## ✨ Features

### 🚀 AI-Powered Development
- **Supermaven**: AI code completion with orange suggestion highlighting and word-by-word acceptance
- **Gemini Integration**: AI-generated commit messages via Google Gemini API with staged diff analysis

### 🔧 Development Tools
- **LSP Ecosystem**: Mason-managed language servers (TypeScript, Go, Rust, Python, Lua, HTML, CSS, SQL) with diagnostic debouncing
- **Code Formatting**: conform.nvim with Prettier, ESLint, and Stylua integration for multi-tool formatting
- **Completion**: nvim-cmp with LSP, path, and buffer sources, plus Supermaven AI integration
- **Syntax Highlighting**: Tree-sitter for 9+ languages with autotagging and incremental selection

### 🔍 Search & Navigation
- **Telescope**: Fuzzy finder with ripgrep, FZF native extension, and smart caching for large codebases
- **NvimTree**: File explorer with Git status integration, LSP file operations, and adaptive sizing
- **Mini.files**: Enhanced file browser with Git status indicators and caching
- **Spectre**: Project-wide search and replace with advanced pattern matching

### 🐙 Git Integration
- **Custom Git Interfaces**: Tabbed floating windows for branch management, status visualization, and remote operations
- **AI Commit Messages**: Gemini-powered commit message generation from staged changes
- **Advanced Workflows**: Staging, branching, merging with visual interfaces and bulk operations
- **Git Blame**: Inline blame annotations with URL opening capabilities

### ⚡ Performance Optimizations
- **Lazy Loading**: Plugins loaded on-demand for fast startup times
- **Debounced LSP**: Reduced diagnostics frequency for smooth editing experience
- **Cached Git Status**: Efficient Git operations with caching in Mini.files
- **Optimized Settings**: Performance-tuned Vim options, disabled built-in plugins, and ripgrep integration

## 📦 Installation

### Prerequisites
- Neovim 0.9+
- Git 2.0+
- Node.js 16+ (for some language servers)
- ripgrep (for Telescope search)
- Optional: Google Gemini API key for AI commit messages

### Setup
1. Clone this repository:
```bash
git clone https://github.com/yourusername/nvim-config ~/.config/nvim
```

2. Install plugins:
```bash
cd ~/.config/nvim
nvim --headless -c 'Lazy sync' +qa
```

3. Set environment variables (optional):
```bash
# For AI commit messages
export GEMINI_API_KEY="your-gemini-api-key"
```

## ⌨️ Key Mappings

### Leader Key: Space

#### 🔍 Navigation & Search
- `<C-p>` - Find files (Telescope with ripgrep and hidden file support)
- `<C-f>` - Live grep search with fixed strings and hidden file inclusion
- `<leader>fw` - Find word under cursor with live grep
- `<leader>fb` - Find buffers with Telescope
- `<leader>bb` - Switch to previous buffer
- `<leader>sw` - Search current word with Spectre (normal and visual modes)
- `<leader>sp` - Search on current file with Spectre

#### 🐙 Git Workflows
- `<leader>ca` - Add all, commit, pull, push with AI-generated commit messages
- `<leader>gb` - Custom Git branch management interface with floating windows
- `<leader>co` - Checkout new branch with input prompt
- `<leader>gp` - Git pull with --no-edit flag
- `<leader>gd` - Git diff view
- `<leader>go` - Open Git blame commit URL

#### 📝 Code Editing
- `<leader>rn` - LSP rename with buffer-local keymaps
- `<leader><leader>` - Format code with multi-tool support (conform.nvim, ESLint, LSP)
- `<leader>qf` - Quick fix/code actions via LSP
- `<leader>p` / `<leader>d` - Improved paste/delete operations without register overwrite
- `<leader>y` / `<leader>Y` - Yank to system clipboard
- `<leader>bf` - Beautify JavaScript with js-beautify

#### 📁 File Management
- `<leader>n` - Toggle NvimTree file explorer
- `<leader>e` - Toggle Mini.files with Git status and reveal CWD
- `<leader>tr` - Reset NvimTree root to project root
- `<leader>tf` - Toggle NvimTree focus
- `<leader>lf` - Go to last file in NvimTree

#### 🔧 Utilities
- `<C-c>` - Copy current file path to clipboard
- `<leader>s` - Source current file
- `<leader>S` - Toggle Spectre search interface

### Window Navigation
- `<C-h/j/k/l>` - Navigate between windows (Vim-style and Tmux-aware)

### Buffer Management
- `<C-d>` / `<C-w>` / `<C-s>` - Close current buffer with Git-aware unsaved change handling
- `<leader>Q` / `<leader>W` - Close all buffers except current
- `gt` / `gT` - Navigate to next/previous buffer

### LSP Integration
- `K` - Hover documentation
- `gd` - Go to definition
- `gD` - Go to declaration
- `gi` - Go to implementation
- `go` - Go to type definition
- `gr` - LSP references (Telescope)
- `gs` - Signature help
- `<F3>` - Format buffer
- `<F4>` - Code actions
- `gl` - Show diagnostics in float
- `[d` / `]d` - Navigate diagnostics

### Custom Git Interface (Branch Command)
- `<CR>` - Execute primary action (checkout branch, toggle staging)
- `<leader>d` - Delete branch (local branches only)
- `<s-M>` - Merge branch
- `c` - Commit staged changes
- `a` - Add all files
- `ra` - Reset all staged files
- `s` - Stash current file
- `<s-S>` - Stash all changes
- `<leader>p` - Pop latest stash
- `<s-P>` - Push current branch
- `<s-F>` - Fetch from remote
- `p` - Pull with --no-edit
- `d` - Open file diff
- `o` - Open file in editor

## 🏗️ Architecture

### Directory Structure
```
├── init.lua                    # Main entry point bootstrapping Lazy.nvim and core modules
├── lua/config/
│   ├── options.lua            # Core Neovim settings, performance optimizations, LSP debouncing
│   ├── plugins/               # Plugin configurations (lazy-loaded)
│   │   ├── init.lua          # Basic plugins (vim-tsx, git-blame, tmux-navigator, theme)
│   │   ├── lsp.lua           # LSP setup with Mason, conform.nvim, TypeScript/Go/Rust/Python support
│   │   ├── completion.lua    # nvim-cmp with LSP/path/buffer sources, Supermaven integration
│   │   ├── telescope.lua     # Fuzzy finder with ripgrep, FZF, smart caching
│   │   ├── super-maven.lua   # AI code completion with custom keybindings
│   │   ├── auto-session.lua  # Session management with NvimTree integration
│   │   ├── comment.lua       # Smart commenting with context awareness
│   │   ├── mini.lua          # Mini plugins collection with Git status integration
│   │   ├── nvim-tree.lua     # File explorer with LSP file operations
│   │   ├── treesitter.lua    # Syntax highlighting for 9+ languages
│   │   ├── dadbod.lua        # Database toolkit with completion
│   │   └── replace.lua       # Spectre search and replace
│   ├── keymaps/              # Organized keymap modules by category
│   │   ├── init.lua          # Keymap loader with categorized imports
│   │   ├── telescope-mappings.lua  # Fuzzy finding (C-p, C-f, leader+fw)
│   │   ├── git-mappings.lua  # AI-powered Git workflows with Gemini integration
│   │   ├── buffer-mappings.lua     # Buffer navigation and management
│   │   ├── code-edit-mappings.lua  # Text manipulation and search
│   │   ├── code-clean-mappings.lua # Formatting and cleanup
│   │   ├── other-mappings.lua      # Utilities and system commands
│   │   ├── personal-mappings.lua   # User preferences
│   │   └── tree-mappings.lua       # NvimTree enhancements
│   └── autocmds.lua          # LSP buffer setup and JsonFormat command
├── lua/personal/             # Custom utilities and Git integration
│   ├── git/
│   │   ├── init.lua          # Git module organizer with tabbed interface
│   │   ├── branch.lua        # Branch management with floating windows
│   │   └── status.lua        # Status visualization and staging
│   └── utils.lua             # Helper functions for bulk operations
├── spell/                    # Custom spell checking
│   ├── en.utf-8.add         # User dictionary
│   └── en.utf-8.add.spl     # Compiled spell file
├── CLAUDE.md                 # Claude Code integration guide
├── README.md                 # Project documentation
├── stylelua.toml            # Lua formatting configuration
├── lazy-lock.json           # Plugin version lockfile
└── .gitignore               # Git ignore patterns
```

### Key Components

#### Core Configuration
- **`init.lua`**: Bootstraps Lazy.nvim and loads all configuration modules with environment variable support
- **`lua/config/options.lua`**: Performance-optimized Vim settings with LSP debouncing, disabled built-ins, and ripgrep integration
- **`lua/config/autocmds.lua`**: LSP buffer setup with key mappings and custom JsonFormat command

#### Plugin Ecosystem
- **LSP**: Mason-managed servers with conform.nvim formatting and diagnostic optimizations
- **Completion**: nvim-cmp with multiple sources and Supermaven AI integration
- **Navigation**: Telescope, NvimTree, Mini.files with Git integration and performance caching
- **Git**: Custom floating interfaces with AI commit message generation and bulk operations

#### Custom Features
- **Git Workflows**: Visual branch/status management with Gemini-powered commits
- **Session Management**: Auto-save/restore with NvimTree integration and bulk session deletion
- **File Operations**: LSP-aware file operations and Git status indicators

## 🎨 Customization

### Adding Plugins
1. Create new file in `lua/config/plugins/[plugin-name].lua`
2. Return plugin spec with lazy loading configuration
3. Plugin auto-loads via Lazy.nvim

### Adding Keymaps
1. Add to appropriate file in `lua/config/keymaps/`
2. Import in `lua/config/keymaps/init.lua` if creating new category
3. Follow existing patterns for consistency

### LSP Configuration
Language servers configured in `lua/config/plugins/lsp.lua`:
- TypeScript/JavaScript: `ts_ls` with custom settings and Prettier formatting
- Python: `pylsp` with flake8 integration
- Go: `gopls`
- Rust: `rust_analyzer`
- Lua: `lua_ls` with Neovim runtime
- HTML/CSS: `html` and `cssls` with schema support

## 📋 Requirements

### System Dependencies
- **Neovim** 0.9+
- **Git** 2.0+
- **Node.js** 16+ (for some LSP servers)
- **ripgrep** (for Telescope search)
- **fd** (optional, for faster file finding)

### Optional AI Features
- **Google Gemini API Key**: For AI commit message generation
- Set `GEMINI_API_KEY` environment variable

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is open source and available under the MIT License.

---

<!-- SYNTAX_PREVIEWS -->
<!-- END_SYNTAX_PREVIEWS -->

*Built with ❤️ for modern development workflows. No more VSCode needed!* 🚀
