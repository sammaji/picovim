local utils = require("lib.utils")

return {
    'MagicDuck/grug-far.nvim',
    opts = function()
        -- options, see Configuration section below
        -- there are no required options atm
        -- engine = 'ripgrep' is default, but 'astgrep' can be specified

        local keymap = vim.keymap
        keymap.set("n", "<leader>fg",
            function()
                require('grug-far').with_visual_selection({
                    prefills = {
                        engine = "astgrep",
                        transient = true,
                        staticTitle = "Find and replace"
                    }
                })
            end,
            utils.desc({}, "Global find and replace.")) -- show definition, references
    end
}
