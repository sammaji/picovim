-- lazy.nvim

local settings = require("config.settings")

return {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    enabled = settings.hard_mode,
    opts = {}
}
