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
                },
                mapping = {
                    ['<TAB>'] = cmp.mapping.select_next_item(),
                    ['<S-TAB>'] = cmp.mapping.select_prev_item(),
                    ['<C-r>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                },
            }

            -- Setup up vim-dadbod
            cmp.setup.filetype({ "sql" }, {
                sources = {
                    { name = "vim-dadbod-completion" },
                    { name = "buffer" },
                },
            })

            for _, ft_path in ipairs(vim.api.nvim_get_runtime_file("lua/config/snippets/*.lua", true)) do
                loadfile(ft_path)()
            end
        end
    },
}
