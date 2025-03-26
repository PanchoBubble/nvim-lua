local function rename_file()
    local source_file = vim.api.nvim_buf_get_name(0)
    local target_file

    vim.api.nvim_echo({ { 'Source file', 'None' }, { source_file, 'None' } }, false, {})
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

return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" }, -- Load only when buffer is opened
        dependencies = {
            "folke/neodev.nvim",
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",

            { "j-hui/fidget.nvim", opts = {} },

            -- Autoformatting
            "stevearc/conform.nvim",

            -- Schema information
            "b0o/SchemaStore.nvim",
        },
        config = function()
            -- Configure diagnostic updates to be less frequent
            vim.diagnostic.config({
                update_in_insert = false, -- disable diagnostics while typing
                virtual_text = {
                    spacing = 4,
                    source = "if_many",
                    prefix = '●',
                },
                severity_sort = true,
                underline = true,
                float = { border = "rounded" },
            })

            -- Add debounce for diagnostics
            vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
                vim.lsp.diagnostic.on_publish_diagnostics,
                {
                    update_in_insert = false,
                    virtual_text = {
                        spacing = 4,
                        source = "if_many",
                    },
                    delay = 300, -- Delay in milliseconds
                }
            )

            require("neodev").setup()
            local lspconfig = require('lspconfig')
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

            require('mason').setup({
                ui = {
                    check_outdated_packages_on_open = false, -- Prevents checking on every open
                    border = "none",
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗"
                    }
                }
            })
            require('mason-lspconfig').setup({
                automatic_installation = true,
                -- Split servers into essential and non-essential
                ensure_installed = {
                    -- Essential (loaded immediately)
                    'ts_ls',
                    'lua_ls',
                    'eslint',

                    -- Non-essential (loaded on demand)
                    'pylsp',
                    'biome',
                    'gopls',
                    'svelte',
                    'rust_analyzer',
                    'html',
                    'denols',
                    'cssls',
                    'sqls'
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
                    ['ts_ls'] = function()
                        lspconfig.gopls.setup {}
                        lspconfig.ts_ls.setup({
                            capabilities = lsp_capabilities,
                            settings = {
                                completions = {
                                    completeFunctionCalls = true
                                },
                                codeActionOnSave = {
                                    enable = true,
                                    mode = "all"
                                },
                                format = false
                            }
                        })
                    end,
                }
            })

            lspconfig.denols.setup {
                root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
            }

            lspconfig.ts_ls.setup {
                root_dir = lspconfig.util.root_pattern("package.json"),
                single_file_support = false
            }

            lspconfig.rust_analyzer.setup {
                -- Server-specific settings. See `:help lspconfig-setup`
                settings = {
                    ['rust-analyzer'] = {},
                },
            }

            -- lspconfig.htmx.setup({
            --     filetypes = { "html", "htmldjango" }
            -- })

            lspconfig.pylsp.setup({
                capabilities = lsp_capabilities,
                configurationSources = { "flake8" },
                settings = {
                    pylsp = {
                        plugins = {
                            pycodestyle = { enabled = false },
                            pyflakes = { enabled = false },
                            flake8 = {
                                enabled = true,
                                config = {
                                    maxComplexity = 11,
                                    maxLineLength = 5000,
                                },
                            },
                        },
                    },
                },
            })

            require('conform').setup({
                formatters_by_ft = {
                    typescript = { "prettierd", "prettier" },
                    typescriptreact = { "prettierd", "prettier" },
                    javascript = { "prettierd", "prettier" },
                    javascriptreact = { "prettierd", "prettier" },
                    mustache = { 'djlint' }
                },
            })
        end,
    },
}
