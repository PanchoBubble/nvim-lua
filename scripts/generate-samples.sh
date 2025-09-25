#!/bin/bash

# Script for batch generation of syntax highlighting previews
# Usage: ./generate-samples.sh [language] [output_format]

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly NVIM_CONFIG_DIR="$(dirname "$SCRIPT_DIR")"
readonly PREVIEW_DIR="$NVIM_CONFIG_DIR/images/syntax-previews"

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

# Check if Neovim is available
check_neovim() {
    if ! command -v nvim >/dev/null 2>&1; then
        log_error "Neovim not found in PATH"
        return 1
    fi
    
    local nvim_version
    nvim_version=$(nvim --version | head -n1 | cut -d' ' -f2)
    log_info "Found Neovim version: $nvim_version"
    return 0
}

# Create preview directory
setup_directories() {
    log_info "Setting up directories..."
    mkdir -p "$PREVIEW_DIR"
    
    # Create temp directory for processing
    local temp_dir="/tmp/nvim-preview-$$"
    mkdir -p "$temp_dir"
    echo "$temp_dir"
}

# Generate preview for a single language
generate_single_preview() {
    local language="$1"
    local temp_dir="$2"
    
    log_info "Generating preview for: $language"
    
    # Create Neovim command to generate preview
    local nvim_cmd="
    lua << EOF
    require('personal.html-export').setup()
    local result = require('personal.html-export').generate_language_preview('$language')
    if result then
        print('SUCCESS: ' .. result)
    else
        print('ERROR: Failed to generate preview')
        vim.cmd('cquit')
    end
    vim.cmd('qall')
EOF
"
    
    # Execute Neovim command
    local output
    if output=$(cd "$NVIM_CONFIG_DIR" && echo "$nvim_cmd" | nvim --headless -c 'set rtp+=$PWD' 2>&1); then
        if echo "$output" | grep -q "SUCCESS:"; then
            local html_file
            html_file=$(echo "$output" | grep "SUCCESS:" | sed 's/SUCCESS: //')
            log_success "Generated: $(basename "$html_file")"
            return 0
        else
            log_error "Preview generation failed for $language"
            log_error "Output: $output"
            return 1
        fi
    else
        log_error "Neovim execution failed for $language"
        log_error "Output: $output"
        return 1
    fi
}

# Generate all language previews
generate_all_previews() {
    local temp_dir="$1"
    local languages=("lua" "javascript" "typescript" "tsx" "python" "go" "rust" "bash" "json" "yaml" "markdown" "html" "css" "sql")
    
    log_info "Generating previews for ${#languages[@]} languages..."
    
    local success_count=0
    local failed_languages=()
    
    for language in "${languages[@]}"; do
        if generate_single_preview "$language" "$temp_dir"; then
            ((success_count++))
        else
            failed_languages+=("$language")
        fi
    done
    
    log_info "Generation complete: $success_count/${#languages[@]} successful"
    
    if [ ${#failed_languages[@]} -gt 0 ]; then
        log_warn "Failed languages: ${failed_languages[*]}"
        return 1
    fi
    
    return 0
}

# Update README with generated previews
update_readme() {
    log_info "Updating README with generated previews..."
    
    local nvim_cmd="
    lua << EOF
    require('personal.readme-generator').setup()
    local success = require('personal.readme-generator').update_readme_with_previews()
    if success then
        print('SUCCESS: README updated')
    else
        print('ERROR: Failed to update README')
        vim.cmd('cquit')
    end
    vim.cmd('qall')
EOF
"
    
    local output
    if output=$(cd "$NVIM_CONFIG_DIR" && echo "$nvim_cmd" | nvim --headless -c 'set rtp+=$PWD' 2>&1); then
        if echo "$output" | grep -q "SUCCESS:"; then
            log_success "README.md updated with syntax previews"
            return 0
        else
            log_error "README update failed"
            log_error "Output: $output"
            return 1
        fi
    else
        log_error "Neovim execution failed for README update"
        log_error "Output: $output"
        return 1
    fi
}

# Clean up old preview files
clean_previews() {
    log_info "Cleaning old preview files..."
    if [ -d "$PREVIEW_DIR" ]; then
        find "$PREVIEW_DIR" -name "*.html" -type f -delete
        log_info "Cleaned preview directory"
    fi
}

# Show usage information
show_usage() {
    cat << EOF
Usage: $0 [COMMAND] [OPTIONS]

COMMANDS:
    all             Generate all language previews and update README
    clean           Clean old preview files
    single LANG     Generate preview for specific language
    readme          Update README with existing previews
    test            Test generation with Lua preview only

OPTIONS:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output

EXAMPLES:
    $0 all                    # Generate all previews and update README
    $0 single lua             # Generate only Lua preview
    $0 clean                  # Clean old preview files
    $0 readme                 # Update README with existing previews

EOF
}

# Main function
main() {
    local command="${1:-all}"
    
    case "$command" in
        -h|--help)
            show_usage
            exit 0
            ;;
        
        clean)
            clean_previews
            ;;
        
        single)
            if [ $# -lt 2 ]; then
                log_error "Language not specified for single command"
                show_usage
                exit 1
            fi
            
            local language="$2"
            check_neovim || exit 1
            local temp_dir
            temp_dir=$(setup_directories)
            
            if generate_single_preview "$language" "$temp_dir"; then
                log_success "Single preview generation completed"
            else
                log_error "Single preview generation failed"
                exit 1
            fi
            ;;
        
        readme)
            check_neovim || exit 1
            update_readme
            ;;
        
        test)
            check_neovim || exit 1
            local temp_dir
            temp_dir=$(setup_directories)
            generate_single_preview "lua" "$temp_dir"
            ;;
        
        all|"")
            log_info "Starting complete preview generation process..."
            
            check_neovim || exit 1
            
            local temp_dir
            temp_dir=$(setup_directories)
            
            clean_previews
            
            if generate_all_previews "$temp_dir"; then
                log_success "All previews generated successfully"
                
                if update_readme; then
                    log_success "Complete process finished successfully!"
                    log_info "Check your README.md for the new syntax highlighting section"
                else
                    log_error "README update failed"
                    exit 1
                fi
            else
                log_error "Preview generation failed"
                exit 1
            fi
            
            # Cleanup temp directory
            rm -rf "$temp_dir"
            ;;
        
        *)
            log_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
