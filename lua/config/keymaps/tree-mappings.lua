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

-- Check if ripgrep is available
local function verify_ripgrep()
  if vim.fn.executable("rg") == 0 then
    vim.notify(
      "ripgrep not found. Install it for live_grep functionality",
      vim.log.levels.ERROR
    )
    return false
  end
  return true
end

-- Safely resolve symlinks with depth limit
local function resolve_symlink(path)
  if not path or path == "" then
    return nil
  end
  
  -- Check if path exists
  if vim.fn.isdirectory(path) == 0 and vim.fn.filereadable(path) == 0 then
    vim.notify("Path does not exist: " .. path, vim.log.levels.ERROR)
    return nil
  end
  
  -- Resolve symlinks safely with max depth
  local resolved = path
  local depth = 0
  local max_depth = 10
  
  while depth < max_depth do
    local link = vim.fn.resolve(resolved)
    if link == resolved then
      break
    end
    resolved = link
    depth = depth + 1
  end
  
  if depth >= max_depth then
    vim.notify("Symlink depth exceeded max: " .. path, vim.log.levels.WARN)
    return path
  end
  
  return resolved
end

-- Check permissions for the given path
local function check_permissions(path)
  -- Verify read permissions
  if vim.fn.filereadable(path) == 0 and vim.fn.isdirectory(path) == 0 then
    return false, "No read permission"
  end
  
  -- Check if directory is accessible
  if vim.fn.isdirectory(path) == 1 then
    if vim.fn.filewritable(path) == 0 then
      return true, "read-only"
    end
  end
  
  return true, "ok"
end

-- Check if directory is empty
local function is_empty_directory(path)
  local entries = vim.fn.readdir(path)
  return #entries == 0
end

-- Live grep function for NvimTree nodes
local function nvim_tree_live_grep()
  -- Check ripgrep availability first
  if not verify_ripgrep() then
    return
  end
  
  -- Get current node from NvimTree
  local api = require("nvim-tree.api")
  local node = api.tree.get_node_under_cursor()
  
  if not node then
    vim.notify("No node selected", vim.log.levels.ERROR)
    return
  end
  
  local path = node.absolute_path
  if not path then
    vim.notify("Unable to get node path", vim.log.levels.ERROR)
    return
  end
  
  -- Resolve symlinks with error handling
  path = resolve_symlink(path)
  if not path then
    vim.notify("Failed to resolve path", vim.log.levels.ERROR)
    return
  end
  
  -- Check permissions
  local has_perms, perm_status = check_permissions(path)
  if not has_perms then
    vim.notify("Permission denied: " .. path, vim.log.levels.ERROR)
    return
  end
  
  if perm_status == "read-only" then
    vim.notify("Directory is read-only, searching anyway", vim.log.levels.WARN)
  end
  
  -- Determine file vs directory and set appropriate search directory
  local is_dir = vim.fn.isdirectory(path) == 1
  local search_dir
  
  if is_dir then
    search_dir = path
    -- Performance check: warn on very large directories
    local entry_count = #vim.fn.readdir(search_dir)
    if entry_count > 10000 then
      vim.notify(
        string.format(
          "Warning: Directory contains %d entries (may be slow)",
          entry_count
        ),
        vim.log.levels.WARN
      )
    end
    
    -- Check for empty directory
    if is_empty_directory(search_dir) then
      vim.notify("Directory is empty: " .. search_dir, vim.log.levels.WARN)
    end
  else
    -- For files, search from parent directory
    search_dir = vim.fn.fnamemodify(path, ":h")
  end
  
  -- Launch Telescope live_grep with error handling
  local ok, err = pcall(function()
    local telescope = require("telescope.builtin")
    telescope.live_grep({
      cwd = search_dir,
      search_dirs = { search_dir },
    })
  end)
  
  if not ok then
    vim.notify("Telescope error: " .. tostring(err), vim.log.levels.ERROR)
  end
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

  -- Add buffer-local mapping for live grep in NvimTree
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "NvimTree",
    callback = function(args)
      vim.keymap.set("n", "ff", nvim_tree_live_grep, {
        buffer = args.buf,
        noremap = true,
        silent = true,
        desc = "Live grep in directory under cursor"
      })
    end,
  })
end

return M
