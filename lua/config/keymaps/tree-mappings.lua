local M = {}

-- Helper function to get git root
local function get_git_root()
  local git_dir = vim.fn.finddir(".git", ".;")
  if git_dir ~= "" then
    return vim.fn.fnamemodify(git_dir, ":h")
  end
  return nil
end

-- Helper function to get the current buffer's project root
local function get_project_root()
  -- Try git root first
  local git_root = get_git_root()
  if git_root then
    return git_root
  end

  -- Fallback to current working directory
  return vim.fn.getcwd()
end

-- Setup nvim-tree with improved root handling
function M.setup()
  local nvim_tree = require "nvim-tree"

  nvim_tree.setup {
    sync_root_with_cwd = true,
    respect_buf_cwd = true,
    update_focused_file = {
      enable = true,
      update_root = true,
    },
    view = {
      preserve_window_proportions = true,
    },
    actions = {
      change_dir = {
        enable = true,
        global = false,
      },
    },
    renderer = {
      root_folder_label = function(path)
        return vim.fn.fnamemodify(path, ":t")
      end,
    },
  }

  -- Create autocommands for better root handling
  local group = vim.api.nvim_create_augroup("NvimTreeRootGroup", { clear = true })

  -- Update root when changing directories
  vim.api.nvim_create_autocmd("DirChanged", {
    group = group,
    callback = function()
      local tree_api = require "nvim-tree.api"
      tree_api.tree.change_root(vim.fn.getcwd())
    end,
  })

  -- Ensure tree root is correct when opening new buffers
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = function()
      local tree_api = require "nvim-tree.api"
      if vim.bo.filetype ~= "NvimTree" then
        local project_root = get_project_root()
        if project_root then
          tree_api.tree.change_root(project_root)
        end
      end
    end,
  })

  -- Add mappings to explicitly control root
  vim.keymap.set("n", "<leader>tr", function()
    local tree_api = require "nvim-tree.api"
    local project_root = get_project_root()
    if project_root then
      tree_api.tree.change_root(project_root)
      vim.notify("Tree root set to: " .. project_root, vim.log.levels.INFO)
    end
  end, { desc = "Reset Tree Root" })

  -- Add mapping to toggle tree focus
  vim.keymap.set("n", "<leader>tf", function()
    local tree_api = require "nvim-tree.api"
    tree_api.tree.toggle { focus = true }
  end, { desc = "Toggle Tree Focus" })
end

return M
