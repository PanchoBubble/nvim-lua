local function rename_file()
  local source_file = vim.api.nvim_buf_get_name(0)
  local target_file

  vim.api.nvim_echo({ { "Source file", "None" }, { source_file, "None" } }, false, {})
  vim.ui.input({
    prompt = "Target : ",
    completion = "file",
    default = source_file,
  }, function(input)
    target_file = input
  end)

  local params = {
    command = "_typescript.applyRenameFile",
    arguments = {
      {
        sourceUri = source_file,
        targetUri = target_file,
      },
    },
    title = "",
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
      vim.diagnostic.config {
        update_in_insert = false, -- disable diagnostics while typing
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
        underline = true,
        float = { border = "rounded" },
      }

      -- Add debounce for diagnostics
      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
        },
        delay = 300, -- Delay in milliseconds
      })

      require("neodev").setup()

      -- Configure lua_ls using the new vim.lsp.config API
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
              },
            },
            completion = {
              callSnippet = "Replace",
            },
          },
        },
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      require("mason").setup {
        ui = {
          check_outdated_packages_on_open = false, -- Prevents checking on every open
          border = "none",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      }
      require("mason-lspconfig").setup {
        automatic_enable = true,
        -- Split servers into essential and non-essential
        ensure_installed = {
          -- Essential (loaded immediately)
          "ts_ls",
          "lua_ls",
          "eslint",
          -- Non-essential (loaded on demand)
          "pylsp",
          -- 'biome',
          "gopls",
          "svelte",
          "rust_analyzer",
          "html",
          -- 'denols',
          "cssls",
          "sqls",
          "jsonls",
        },
        handlers = {
          function(server_name)
            -- Configure the server with capabilities and commands
            vim.lsp.config(server_name, {
              capabilities = lsp_capabilities,
              commands = {
                RenameFile = {
                  rename_file,
                  description = "Rename File",
                },
              },
            })
            -- Enable the server
            vim.lsp.enable(server_name)
          end,
          ["jsonls"] = function()
            vim.lsp.config("jsonls", {
              capabilities = lsp_capabilities,
              settings = {
                json = {
                  format = {
                    tabSize = 2,
                  },
                },
              },
            })
            vim.lsp.enable("jsonls")
          end,
          ["ts_ls"] = function()
            -- Configure gopls
            vim.lsp.config("gopls", {
              capabilities = lsp_capabilities,
            })
            vim.lsp.enable "gopls"

            -- Configure ts_ls with React support and formatting capabilities
            vim.lsp.config("ts_ls", {
              capabilities = lsp_capabilities,
              filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
              root_markers = { "package.json", "tsconfig.json", ".git" },
              single_file_support = false,
              init_options = {
                preferences = {
                  includeInlayParameterNameHints = "all",
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                  includeInlayFunctionParameterTypeHints = true,
                  includeInlayVariableTypeHints = true,
                  includeInlayPropertyDeclarationTypeHints = true,
                  includeInlayFunctionLikeReturnTypeHints = true,
                  includeInlayEnumMemberValueHints = true,
                },
              },
              settings = {
                typescript = {
                  format = {
                    enable = true,
                  },
                  inlayHints = {
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                  },
                },
                javascript = {
                  format = {
                    enable = true,
                  },
                },
                completions = {
                  completeFunctionCalls = true,
                },
                codeActionOnSave = {
                  enable = true,
                  mode = "all",
                },
              },
            })
            vim.lsp.enable "ts_ls"
          end,
        },
      }

      -- Configure rust_analyzer
      vim.lsp.config("rust_analyzer", {
        capabilities = lsp_capabilities,
        settings = {
          ["rust-analyzer"] = {},
        },
      })

      -- Configure pylsp with flake8
      vim.lsp.config("pylsp", {
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

      -- Optional: denols configuration (commented out)
      -- vim.lsp.config('denols', {
      --     root_markers = { "deno.json", "deno.jsonc" },
      -- })

      -- Optional: htmx configuration (commented out)
      -- vim.lsp.config('htmx', {
      --     filetypes = { "html", "htmldjango" }
      -- })

      require("conform").setup {
        formatters_by_ft = {
          typescript = { "prettier" },
          typescriptreact = { "prettier" },
          javascript = { "prettier" },
          javascriptreact = { "prettier" },
          json = { "prettier" },
          jsonc = { "prettier" },
          -- mustache = { 'djlint' }
        },
      }
    end,
  },
}
