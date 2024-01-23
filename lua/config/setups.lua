-- LAZY PLUGINS
local plugins = require('config.plugins')
require("lazy").setup(plugins)

-- CMP TAGS
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
    sources = {
        { name = 'nvim_lsp' },
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<TAB>'] = cmp.mapping.select_next_item(),
        ['<S-TAB>'] = cmp.mapping.select_prev_item(),
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
        'eslint',
        'html',
        'cssls'
    },
    handlers = {
        function(server)
            lspconfig[server].setup({
                capabilities = lsp_capabilities,
            })
        end,
        ['tsserver'] = function()
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
    sync_install = true,
    auto_install = true,
    ignore_install = {},
    highlight = { enable = true },
    indent = { enable = true },
    ensure_installed = {
        "bash",
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
