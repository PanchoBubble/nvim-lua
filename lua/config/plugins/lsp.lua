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
            require("neodev").setup {
                -- library = {
                --   plugins = { "nvim-dap-ui" },
                --   types = true,
                -- },
            }

            local lspconfig = require('lspconfig')
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

            require('mason').setup({})
            require('mason-lspconfig').setup({
                ensure_installed = {
                    'ts_ls',
                    'pylsp',
                    'luau_lsp',
                    'gopls',
                    'rust_analyzer',
                    'eslint',
                    'html',
                    'denols',
                    'htmx',
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

            lspconfig.htmx.setup({
                filetypes = { "html", "htmldjango" }
            })

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
                    mustache = 'djlint',
                },
            })
        end,
    },
}
