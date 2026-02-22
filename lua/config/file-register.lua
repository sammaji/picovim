-- This module manages a persistent list of file paths (like a manual register).
-- It requires the 'plenary.nvim' utility library for simple file operations.

local M = {}
local vim = vim

-- --- Configuration ---

---@type string
-- Defines the file where the marked list will be stored for persistence.
local REGISTER_FILE_NAME = 'custom_file_register.json'

---@type string
-- Get the Neovim data directory (e.g., ~/.local/share/nvim)
local DATA_PATH = vim.fn.stdpath('data') .. '/'

---@type string
-- The full path to the persistence file.
local FULL_PATH = DATA_PATH .. REGISTER_FILE_NAME

-- --- Internal Utility Functions ---

---Loads the persistent file list from the JSON file.
---@return string[]
local function load_list()
    local json_string = vim.fn.readfile(FULL_PATH)
    if #json_string == 0 then
        return {}
    end
    -- Readfile returns a table of strings, one per line. We join them.
    local list_content = table.concat(json_string, '\n')
    local ok, list = pcall(vim.json.decode, list_content)
    if not ok or type(list) ~= 'table' then
        vim.notify('Error decoding custom file register file.', vim.log.levels.ERROR)
        return {}
    end
    return list
end

---Saves the current file list back to the JSON file.
---@param list string[]
local function save_list(list)
    local json_string = vim.json.encode(list)
    -- The vim.fn.writefile function expects a table of lines.
    local ok = pcall(vim.fn.writefile, { json_string }, FULL_PATH)
    if not ok then
        vim.notify('Error writing to custom file register file.', vim.log.levels.ERROR)
    end
end

-- --- Public API Functions ---

---Adds the current buffer's file path to the persistent list.
function M.add_current_file()
    local file_path = vim.fn.expand('%:p')
    if file_path == '' then
        vim.notify('Current buffer is not a file.', vim.log.levels.WARN)
        return
    end

    local list = load_list()

    -- Ensure the list only contains unique file paths
    for _, path in ipairs(list) do
        if path == file_path then
            vim.notify('File already in register.', vim.log.levels.INFO)
            return
        end
    end

    table.insert(list, file_path)
    save_list(list)
    vim.notify('Added ' .. vim.fn.fnamemodify(file_path, ':t') .. ' to register.', vim.log.levels.INFO)
end

---Deletes the selected file path from the persistent list.
---@param path string
function M.delete_file(path)
    local list = load_list()
    local new_list = {}
    local found = false
    for _, file_path in ipairs(list) do
        if file_path ~= path then
            table.insert(new_list, file_path)
        else
            found = true
        end
    end

    if found then
        save_list(new_list)
        vim.notify('Removed ' .. vim.fn.fnamemodify(path, ':t') .. ' from register.', vim.log.levels.INFO)
    else
        vim.notify('File not found in register.', vim.log.levels.ERROR)
    end
end

---Opens the custom file register using Telescope.
function M.pick_file()
    local list = load_list()
    local telescope = require('telescope')

    -- Handle case where the list is empty
    if #list == 0 then
        vim.notify('Custom file register is empty. Use <leader>a to add files.', vim.log.levels.INFO)
        return
    end

    -- Use Telescope's pickers utility to create a custom picker from the list
    telescope.extensions.vim_native.pickers.custom_list({
        prompt = 'Custom File Register',
        entry_maker = function(entry)
            -- This function customizes how Telescope displays each entry
            local filename = vim.fn.fnamemodify(entry, ':t')
            local path_display = vim.fn.fnamemodify(entry, ':~:s?$') -- Displays relative path and removes trailing slash
            return {
                value = entry,                                       -- The actual value (full path) to return on selection
                display = string.format('%-30s %s', filename, path_display),
                ordinal = entry,
                -- Action to take when user presses <C-d> in the picker (for 'Delete')
                action_delete = function()
                    -- Use a short delay before calling delete to allow Telescope to close/update
                    vim.defer_fn(function()
                        M.delete_file(entry)
                        -- Re-open the picker after deletion
                        M.pick_file()
                    end, 50)
                end,
            }
        end,
        -- Map <C-d> in the Telescope prompt to the custom delete action
        attach_mappings = function(prompt_bufnr, map)
            local actions = require('telescope.actions')
            local action_state = require('telescope.actions.state')

            map('i', '<C-d>', function()
                local entry = action_state.get_selected_entry()
                if entry and entry.action_delete then
                    entry.action_delete()
                end
            end)
            return true
        end,
        finder = require('telescope.finders').new_table({
            results = list,
        }),
        sorter = require('telescope.sorters').get_generic_fuzzy_sorter(),
    }):find()
end

return M
