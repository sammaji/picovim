local disable_treesitter = function()
    --[[if vim.fn.exists(":TSBufDisable") then
        vim.cmd("TSBufDisable autotag")
        vim.cmd("TSBufDisable highlight")
    end]]
    vim.cmd("set foldmethod=manual")
    vim.cmd("syntax clear")
    vim.cmd("syntax off")
    vim.cmd("filetype off")
    vim.cmd("set noundofile")
    vim.cmd("set noswapfile")
    vim.cmd("set noloadplugins")
end

local settings = require("config.settings")
local disable_by_default = settings.workspace.disable_neovim_syntax_features

if disable_by_default then
    disable_treesitter()
end

-- optimize neovim for opening large files.
vim.api.nvim_create_user_command(
    "DisableTreesitter",
    disable_treesitter,
    { desc = "Disable treesitter (useful for large files.)" }
)

vim.api.nvim_create_user_command(
    "EnableTreesitter",
    function(args)
        --[[if vim.fn.exists(":TSBufEnable") then
            vim.cmd("TSBufEnable autotag")
            vim.cmd("TSBufEnable highlight")
        end]]
        vim.cmd("set foldmethod=indent")
        vim.cmd("syntax on")
        vim.cmd("filetype plugin indent on")
        vim.cmd("set undofile")
        vim.cmd("set swapfile")
        vim.cmd("set loadplugins")
    end,
    { desc = "Disable treesitter (useful for large files.)" }
)
