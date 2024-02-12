-- LAZY PLUGINS
local plugins = require('config.plugins')
require("lazy").setup(plugins)

local function rename_file()
    local source_file, target_file

    vim.ui.input({
            prompt = "Source : ",
            completion = "file",
            default = vim.api.nvim_buf_get_name(0)
        },
        function(input)
            source_file = input
        end
    )
    vim.ui.input({
            prompt = "Target : ",
            completion = "file",
            default = source_file
        },
        function(input)
            target_file = input
        end
    )

    local params = {
        command = "_typescript.applyRenameFile",
        arguments = {
            {
                sourceUri = source_file,
                targetUri = target_file,
            },
        },
        title = ""
    }

    vim.lsp.util.rename(source_file, target_file, {})
    vim.lsp.buf.execute_command(params)
end

-- CMP TAGS
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
    sources = {
        { name = 'nvim_lsp' },
    },
    mapping = cmp.mapping.preset.insert({
        ['<TAB>'] = cmp.mapping.select_next_item(),
        ['<S-TAB>'] = cmp.mapping.select_prev_item(),
        ['<C-r>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
    }),
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end
    },
})

-- LSP
local lspconfig = require('lspconfig')
local capabilities = vim.lsp.protocol.make_client_capabilities()
local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {
        'tsserver',
        'pyright',
        'gopls',
        'eslint',
        'html',
        'cssls'
    },
    handlers = {
        function(server)
            lspconfig[server].setup({
                capabilities = lsp_capabilities,
                commands = {
                    RenameFile = {
                        rename_file,
                        description = "Rename File"
                    },
                }
            })
        end,
        ['tsserver'] = function()
            lspconfig.gopls.setup {}
            lspconfig.tsserver.setup({
                capabilities = lsp_capabilities,
                settings = {
                    completions = {
                        completeFunctionCalls = true
                    },
                    codeActionOnSave = {
                        enable = true,
                        mode = "all"
                    },
                }
            })
        end
    }
})

lspconfig.pyright.setup {
    --on_attach = on_attach,
    settings = {
        pyright = {
            autoImportCompletion = true,
        },
        python = {
            analysis = {
                autoSearchPaths = true, diagnosticMode = 'openFilesOnly', useLibraryCodeForTypes = true, typeCheckingMode = 'off'
            }
        }
    }
}

-- SESSION
require('auto-session').setup {
    auto_session_enable_last_session = vim.loop.cwd() == vim.loop.os_homedir(),
    post_restore_cmds = { "NvimTreeFindFile" },
    pre_save_cmds = { "NvimTreeClose" },
    log_level = 'warn',
    auto_session_enabled = true
}
-- NVIM TREE
require("nvim-tree").setup({
    git = {
        enable = true,
        ignore = false,
        timeout = 500,
    },
    view = { adaptive_size = true },
    update_cwd = true,
    filters = {
        dotfiles = false,
    },
    update_focused_file = {
        enable = true,
        update_cwd = true,
    },
    filesystem_watchers = {
        enable = true,
        debounce_delay = 50,
        ignore_dirs = { "node_modules" },
    },
})

-- TreeSitter
require('nvim-treesitter.configs').setup({
    modules = {},
    -- rainbow = { enable = true },
    autotag = { enable = true },
    sync_install = true,
    auto_install = true,
    ignore_install = {},
    highlight = { enable = true },
    indent = { enable = true },
    ensure_installed = {
        "bash",
        "go",
        "html",
        "javascript",
        "json",
        "graphql",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "typescript",
        "vim",
        "yaml",
    },
})
require("bufferline").setup({
    options = {
        offsets = {
            {
                filetype = "NvimTree",
                text = "Nvim Tree",
                separator = true,
                text_align = "left"
            }
        },
    }
})


require('Comment').setup()
require('spectre').setup({})
