-- Core functionality mappings
local core_mappings = {
    'code-edit-mappings',    -- Code editing related mappings
    'code-clean-mappings',   -- Code cleaning and formatting
    'buffer-mappings',       -- Buffer management
}

-- Tool integration mappings
local tool_mappings = {
    'tree-mappings',        -- Nvim-tree with improved root handling
    'telescope-mappings',    -- Telescope fuzzy finder
    'git-mappings',         -- Git operations
}

-- Custom mappings
local custom_mappings = {
    'personal-mappings',    -- Personal user preferences
    'other-mappings',       -- Miscellaneous mappings
    'avante-mappings',      -- Avante-specific mappings
}

-- Load all mapping modules
local function load_mappings(mapping_list)
    for _, mapping in ipairs(mapping_list) do
        local ok, err = pcall(require, 'config.keymaps.' .. mapping)
        if not ok then
            vim.notify('Failed to load ' .. mapping .. ': ' .. err, vim.log.levels.ERROR)
        end
    end
end

-- Initialize mappings in order
load_mappings(core_mappings)
load_mappings(tool_mappings)
load_mappings(custom_mappings)

-- Set up a global check for Avante buffers
_G.is_avante_buffer = require('config.keymaps.avante-mappings').is_avante_buffer
