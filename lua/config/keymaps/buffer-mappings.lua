-- Buffer navigation
vim.keymap.set("n", "<C-j>", "<C-w><C-j>")
vim.keymap.set("n", "<C-k>", "<C-w><C-k>")
vim.keymap.set("n", "<C-h>", "<C-w><C-h>")
vim.keymap.set("n", "<C-l>", "<C-w><C-l>")

vim.keymap.set("n", "<leader>bb", "<C-^><CR>") -- Go to previous file
vim.keymap.set("n", "gd", vim.lsp.buf.implementation) -- Go to implementation

-- Copy current file path to clipboard
local function copyFilePath()
  vim.fn.setreg("+", vim.fn.expand("%"))
  vim.notify("Copied file path to clipboard!")
end
vim.keymap.set("n", "<C-c>", copyFilePath)

vim.keymap.set("n", "<leader>n", "<cmd>NvimTreeToggle<CR>") -- Toggle NvimTree

vim.keymap.set("n", "gt", "<cmd>bnext<CR>") -- Go to next buffer
vim.keymap.set("n", "gT", "<cmd>bprev<CR>") -- Go to previous buffer

-- Close buffers, handling NvimTree
local function closeBuffers(closeAll)
  local isOpen = require("nvim-tree.view").is_visible()
  if isOpen then
    vim.cmd("NvimTreeClose")
  end

  if closeAll then
    local bufs = vim.api.nvim_list_bufs()
    local currentBuf = vim.api.nvim_get_current_buf()
    for _, buf in ipairs(bufs) do
      if buf ~= currentBuf and vim.fn.bufname(buf) ~= vim.fn.expand("$NVIM_TREENAME") then
        vim.api.nvim_buf_delete(buf, {})
      end
    end
  else
    vim.cmd("bd")
  end

  if isOpen then
    vim.cmd("NvimTreeOpen")
    vim.cmd("bnext")
  end
end

vim.keymap.set("n", "<C-d>", function() closeBuffers(false) end) -- Close current buffer
vim.keymap.set("n", "<C-w>", function() closeBuffers(false) end) -- Close current buffer
vim.keymap.set("n", "<C-s>", function() closeBuffers(true) end) -- Close all buffers but current
vim.keymap.set("n", "<leader>Q", function() closeBuffers(true) end) -- Close all buffers but current
vim.keymap.set("n", "<leader>W", function() closeBuffers(true) end) -- Close all buffers but current

-- Neovide specific keybindings
if vim.g.neovide then
  vim.keymap.set("n", "<D-s>", ":w<CR>")  -- Save
  vim.keymap.set("v", "<D-c>", '"+y')    -- Copy
  vim.keymap.set({ "n", "v", "c", "i" }, "<D-v>", '"+p') -- Paste in all modes
end
