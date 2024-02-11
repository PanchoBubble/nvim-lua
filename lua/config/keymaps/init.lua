vim.g.mapleader = " "

vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>")

require('config.keymaps.code-edit-mappings')
require('config.keymaps.code-clean-mappings')
require('config.keymaps.buffer-mappings')
require('config.keymaps.telescope-mappings')
require('config.keymaps.trouble-maker-mappings')
require('config.keymaps.other-mappings')
