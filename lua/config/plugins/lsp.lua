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
          "jsonls",
        },
        handlers = {
          function(server_name)
            -- Skip sqls to prevent database connection errors
            if server_name == "sqls" then
              return
            end
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

            -- Configure ts_ls with React support, formatting disabled for performance
            vim.lsp.config("ts_ls", {
              capabilities = lsp_capabilities,
              filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
              root_markers = { "package.json", "tsconfig.json", ".git" },
              single_file_support = false,
              init_options = {
                preferences = {
                  includeCompletionsForModuleExports = true,
                  quotePreference = "auto",
                  includePackageJsonAutoImports = "auto",
                },
              },
              settings = {
                typescript = {
                  -- Disable formatting to prevent conflicts with conform.nvim
                  format = {
                    enable = false,
                  },
                  -- Minimal inlay hints for performance
                  inlayHints = {
                    includeInlayParameterNameHints = "literals",
                    includeInlayFunctionParameterTypeHints = false,
                    includeInlayVariableTypeHints = false,
                    includeInlayPropertyDeclarationTypeHints = false,
                    includeInlayFunctionLikeReturnTypeHints = false,
                    includeInlayEnumMemberValueHints = false,
                  },
                },
                javascript = {
                  format = {
                    enable = false,
                  },
                },
                completions = {
                  completeFunctionCalls = true,
                },
                -- Disable code actions on save for performance
                codeActionOnSave = {
                  enable = false,
                },
              },
              -- Override server capabilities to disable formatting
              on_attach = function(client, bufnr)
                -- Disable formatting capabilities to prevent conflicts
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
              end,
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

      -- Setup debug utilities
      require('personal.debug').setup()

      require("conform").setup {
        formatters_by_ft = {
          -- Use prettierd for faster formatting
          typescript = { "prettierd", "prettier" },
          typescriptreact = { "prettierd", "prettier" },
          javascript = { "prettierd", "prettier" },
          javascriptreact = { "prettierd", "prettier" },
          json = { "prettierd", "prettier" },
          jsonc = { "prettierd", "prettier" },
          css = { "prettierd", "prettier" },
          scss = { "prettierd", "prettier" },
          html = { "prettierd", "prettier" },
          yaml = { "prettierd", "prettier" },
          markdown = { "prettierd", "prettier" },
        },
        -- Disable format_on_save to avoid conflicts, use manual formatting only
        format_on_save = false,
        -- Set default format options
        default_format_opts = {
          timeout_ms = 3000,
          async = false,
          quiet = false,
          lsp_fallback = false,  -- Explicitly disable LSP fallback to prevent conflicts
        },
        -- Configure prettierd for performance
        formatters = {
          prettierd = {
            env = {
              string.format("PRETTIERD_DEFAULT_CONFIG=%s", vim.fn.expand("~/.config/nvim/prettier.config.js") or ""),
            },
          },
        },
      }
    end,
  },
}
