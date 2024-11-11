return {
    {
        "hrsh7th/nvim-cmp",
        lazy = false,
        priority = 100,
        dependencies = {
            "onsails/lspkind.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
            { "L3MON4D3/LuaSnip", build = "make install_jsregexp", version = "v2.3.0" },
            "saadparwaiz1/cmp_luasnip",
        },

        config = function()
            vim.opt.completeopt = { "menu", "menuone", "noselect" }
            vim.opt.shortmess:append "c"

            local lspkind = require "lspkind"
            lspkind.init {
                symbol_map = {
                    Supermaven = "",
                },
            }
            vim.api.nvim_set_hl(0, "CmpItemKindSupermaven", { fg = "#6CC644" })

            local cmp = require "cmp"

            cmp.setup {
                sources = {
                    { name = "nvim_lsp" },
                    { name = "path" },
                    { name = "buffer" },
                    { name = "supermaven" },
                },
                mapping = {
                    ['<TAB>'] = cmp.mapping.select_next_item(),
                    ['<S-TAB>'] = cmp.mapping.select_prev_item(),
                    ['<C-r>'] = cmp.mapping.complete(),
                    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                },

                -- Enable luasnip to handle snippet expansion for nvim-cmp
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
            }

            -- Setup up vim-dadbod
            cmp.setup.filetype({ "sql" }, {
                sources = {
                    { name = "vim-dadbod-completion" },
                    { name = "buffer" },
                },
            })

            local ls = require "luasnip"
            ls.config.set_config {
                history = false,
                updateevents = "TextChanged,TextChangedI",
            }

            for _, ft_path in ipairs(vim.api.nvim_get_runtime_file("lua/config/snippets/*.lua", true)) do
                loadfile(ft_path)()
            end

            vim.keymap.set({ "i", "s" }, "<c-k>", function()
                if ls.expand_or_jumpable() then
                    ls.expand_or_jump()
                end
            end, { silent = true })

            vim.keymap.set({ "i", "s" }, "<c-j>", function()
                if ls.jumpable(-1) then
                    ls.jump(-1)
                end
            end, { silent = true })
        end
    },
}
