-- Buffer navigation
vim.keymap.set("n", "<C-j>", "<C-w><C-j>")
vim.keymap.set("n", "<C-k>", "<C-w><C-k>")
vim.keymap.set("n", "<C-h>", "<C-w><C-h>")
vim.keymap.set("n", "<C-l>", "<C-w><C-l>")

vim.keymap.set("n", "<leader>bb", "<C-^><CR>")        -- Go to previous file
vim.keymap.set("n", "gd", vim.lsp.buf.implementation) -- Go to implementation

-- Copy current file path to clipboard
local function copyFilePath()
    vim.fn.setreg("+", vim.fn.expand("%"))
    vim.notify("Copied file path to clipboard!")
end
vim.keymap.set("n", "<C-c>", copyFilePath)

vim.keymap.set("n", "<leader>n", "<cmd>NvimTreeToggle<CR>") -- Toggle NvimTree

vim.keymap.set("n", "gt", "<cmd>bnext<CR>")                 -- Go to next buffer
vim.keymap.set("n", "gT", "<cmd>bprev<CR>")                 -- Go to previous buffer

-- Check if file is in git repository
local function is_in_git_repo(filepath)
    -- Get the absolute path
    local abs_path = vim.fn.fnamemodify(filepath, ':p')
    -- Try to get git root directory
    local git_root = vim.fn.system('git -C ' .. vim.fn.shellescape(vim.fn.fnamemodify(abs_path, ':h')) .. ' rev-parse --show-toplevel 2>/dev/null')
    return vim.v.shell_error == 0 and git_root ~= ""
end

-- Close buffers, handling NvimTree
local function closeBuffers(closeAll)
    local isOpen = require("nvim-tree.view").is_visible()
    if isOpen then
        vim.cmd("NvimTreeClose")
    end

    local unsaved_buffers = {}

    if closeAll then
        local bufs = vim.api.nvim_list_bufs()
        local currentBuf = vim.api.nvim_get_current_buf()
        for _, buf in ipairs(bufs) do
            -- Skip current buffer, NvimTree, and non-loaded buffers
            if buf ~= currentBuf
                and vim.fn.bufname(buf) ~= vim.fn.expand("$NVIM_TREENAME")
                and vim.api.nvim_buf_is_loaded(buf) then
                -- Check if buffer has unsaved changes
                if vim.bo[buf].modified then
                    local bufname = vim.api.nvim_buf_get_name(buf)
                    -- Only preserve changes for files in git repo
                    if is_in_git_repo(bufname) then
                        local display_name = vim.fn.fnamemodify(bufname, ':~:.')
                        table.insert(unsaved_buffers, display_name)
                    else
                        -- Force close non-repo files with changes
                        pcall(vim.api.nvim_buf_delete, buf, { force = true })
                    end
                else
                    -- Only delete if no unsaved changes
                    pcall(vim.api.nvim_buf_delete, buf, {})
                end
            end
        end
    else
        -- For single buffer close
        local current_buf = vim.api.nvim_get_current_buf()
        if vim.bo[current_buf].modified then
            local bufname = vim.api.nvim_buf_get_name(current_buf)
            if is_in_git_repo(bufname) then
                local display_name = vim.fn.fnamemodify(bufname, ':~:.')
                table.insert(unsaved_buffers, display_name)
            else
                -- Force close non-repo files with changes
                vim.cmd("bd!")
            end
        else
            vim.cmd("bd")
        end
    end

    if isOpen then
        vim.cmd("NvimTreeOpen")
        vim.cmd("bnext")
    end

    -- Notify about unsaved buffers (only for files in git repo)
    if #unsaved_buffers > 0 then
        local msg = "Unsaved buffers not closed:\n- " .. table.concat(unsaved_buffers, "\n- ")
        vim.notify(msg, vim.log.levels.WARN, {
            title = "Buffer Close",
            timeout = 5000
        })
    end
end

vim.keymap.set("n", "<C-d>", function() closeBuffers(false) end)    -- Close current buffer
vim.keymap.set("n", "<C-w>", function() closeBuffers(false) end)    -- Close current buffer
vim.keymap.set("n", "<C-s>", function() closeBuffers(true) end)     -- Close all buffers but current
vim.keymap.set("n", "<leader>Q", function() closeBuffers(true) end) -- Close all buffers but current
vim.keymap.set("n", "<leader>W", function() closeBuffers(true) end) -- Close all buffers but current

-- Neovide specific keybindings
if vim.g.neovide then
    vim.keymap.set("n", "<D-s>", ":w<CR>")                 -- Save
    vim.keymap.set("v", "<D-c>", '"+y')                    -- Copy
    vim.keymap.set({ "n", "v", "c", "i" }, "<D-v>", '"+p') -- Paste in all modes
end

local api = require("nvim-tree.api")
function GoToLastFile()
    local node = api.tree.get_node_under_cursor()
    local parent = node.parent or node
    local last_node = parent.nodes[#parent.nodes]
    if last_node.type == "file" then
        api.node.open.edit(last_node)
    end
end

vim.keymap.set("n", "<leader>lf", GoToLastFile, { desc = "Go to last file in NvimTree" })
