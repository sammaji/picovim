-- This config file sets up the commands and keymaps for the custom file register.

-- Ensure the Lua module is loaded
local file_register = require('config.file-register')

-- 1. Setup Custom Commands
-- These commands allow you to manually manage the list using the colon prompt.

vim.api.nvim_create_user_command('CustomFileRegisterAdd', function()
    file_register.add_current_file()
end, {
    desc = 'Add current file to the Custom File Register list.',
})

vim.api.nvim_create_user_command('CustomFileRegisterPick', function()
    file_register.pick_file()
end, {
    desc = 'Open Telescope picker for Custom File Register.',
})

-- 2. Setup Keymaps
-- This makes the workflow fast and accessible.

vim.keymap.set('n', '<leader>aa', '<cmd>CustomFileRegisterAdd<CR>', {
    desc = '[A]dd current file to custom register',
})

vim.keymap.set('n', '<leader>ab', '<cmd>CustomFileRegisterPick<CR>', {
    desc = 'Open [F]ile Register Picker (Telescope)',
})

-- 3. Configuration Notes

-- Usage:
-- 1. Go to any file you want to mark.
-- 2. Press <leader>a (or run :CustomFileRegisterAdd) to add it.
-- 3. Press <leader>f (or run :CustomFileRegisterPick) to open the Telescope picker.
-- 4. In the picker, you can fuzzy search or use <C-d> to delete an entry.
