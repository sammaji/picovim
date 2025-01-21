require("config.autocmds")
require("config.opts")
require("config.lazy")

local settings = require("config.settings")
vim.cmd("colorscheme " .. settings.theme.name)

require("config.commands")
