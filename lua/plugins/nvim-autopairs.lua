local settings = require("config.settings")

    {
        'm4xshen/autoclose.nvim',
        opts = {
            disabled_filetypes = { "text" },
            options = {
                auto_indent = true
            }
        },
        enabled = settings.auto_pairs,
    }
