return {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
        'akinsho/bufferline.nvim',
    },
    config = function()
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
    end
}
