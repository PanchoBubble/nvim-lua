#!/bin/bash

# Script to format all Lua files in the Neovim configuration
# Usage: ./format-lua.sh [--check] [--install]

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly NVIM_CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if stylua is installed
check_stylua() {
    if command -v stylua >/dev/null 2>&1; then
        local version
        version=$(stylua --version | awk '{print $2}')
        log_info "Found stylua version: $version"
        return 0
    else
        log_warn "stylua not found in PATH"
        return 1
    fi
}

# Install stylua via Homebrew
install_stylua() {
    log_info "Installing stylua via Homebrew..."
    
    if ! command -v brew >/dev/null 2>&1; then
        log_error "Homebrew not found. Please install Homebrew first:"
        log_error "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        return 1
    fi
    
    if brew install stylua; then
        log_success "stylua installed successfully"
        return 0
    else
        log_error "Failed to install stylua"
        return 1
    fi
}

# Format all Lua files
format_lua_files() {
    local check_only="${1:-false}"
    
    log_info "Searching for Lua files in $NVIM_CONFIG_DIR..."
    
    local lua_files
    lua_files=$(find "$NVIM_CONFIG_DIR" -name "*.lua" -not -path "*/\.git/*" -not -path "*/lazy-lock.json/*")
    
    local file_count
    file_count=$(echo "$lua_files" | wc -l | xargs)
    
    log_info "Found $file_count Lua files"
    
    if [ "$check_only" = true ]; then
        log_info "Running stylua in check mode..."
        
        if echo "$lua_files" | xargs stylua --check --config-path "$NVIM_CONFIG_DIR/stylelua.toml"; then
            log_success "All files are properly formatted!"
            return 0
        else
            log_error "Some files need formatting. Run without --check to format them."
            return 1
        fi
    else
        log_info "Formatting Lua files..."
        
        local formatted_count=0
        while IFS= read -r file; do
            if [ -n "$file" ]; then
                log_info "Formatting: ${file#$NVIM_CONFIG_DIR/}"
                if stylua --config-path "$NVIM_CONFIG_DIR/stylelua.toml" "$file"; then
                    ((formatted_count++))
                else
                    log_error "Failed to format: $file"
                fi
            fi
        done <<< "$lua_files"
        
        log_success "Formatted $formatted_count files"
        return 0
    fi
}

# Show usage information
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
    --check         Check if files are formatted without modifying them
    --install       Install stylua via Homebrew if not present
    -h, --help      Show this help message

EXAMPLES:
    $0                    # Format all Lua files
    $0 --check            # Check formatting without modifying files
    $0 --install          # Install stylua and format all files

CONFIGURATION:
    stylua.toml in the root directory controls formatting rules

EOF
}

# Main function
main() {
    local check_only=false
    local install_mode=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --check)
                check_only=true
                shift
                ;;
            --install)
                install_mode=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    log_info "Starting Lua formatting process..."
    
    # Check or install stylua
    if ! check_stylua; then
        if [ "$install_mode" = true ]; then
            install_stylua || exit 1
        else
            log_error "stylua is not installed. Run with --install to install it:"
            log_error "  $0 --install"
            exit 1
        fi
    fi
    
    # Check if config file exists
    if [ ! -f "$NVIM_CONFIG_DIR/stylelua.toml" ]; then
        log_warn "stylelua.toml not found, using default settings"
    fi
    
    # Format files
    if format_lua_files "$check_only"; then
        log_success "Formatting process completed successfully!"
        
        if [ "$check_only" = false ]; then
            log_info "Remember to review changes with 'git diff' before committing"
        fi
        
        exit 0
    else
        log_error "Formatting process failed"
        exit 1
    fi
}

# Run main function with all arguments
main "$@"
