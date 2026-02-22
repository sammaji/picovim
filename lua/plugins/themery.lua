local themes = {
    -- --- THE MODERN CLASSICS (Reliable & Polished) ---
    { repo = "rebelot/kanagawa.nvim",            name = "kanagawa" },
    { repo = "folke/tokyonight.nvim",            name = "tokyonight" },
    { repo = "rose-pine/neovim",                 name = "rose-pine" },
    { repo = "catppuccin/nvim",                  name = "catppuccin" },

    -- --- THE HIGH-CONTRAST / FUTURISTIC ---
    { repo = "scottmckendry/cyberdream.nvim",    name = "cyberdream" },
    { repo = "EdenEast/nightfox.nvim",           name = "nightfox" }, -- Includes carbonfox, terafox
    { repo = "mellow-theme/mellow.nvim",         name = "mellow" },
    { repo = "Verf/deepwhite.nvim",              name = "deepwhite" },

    -- --- THE EARTHY / ORGANIC ---
    { repo = "sainnhe/everforest",               name = "everforest" },
    { repo = "sainnhe/gruvbox-material",         name = "gruvbox-material" },
    { repo = "ribru17/bamboo.nvim",              name = "bamboo" },

    -- --- THE UNIQUE / NEW GADGETS ---
    { repo = "nyoom-engineering/oxocarbon.nvim", name = "oxocarbon" }, -- Minimalist / IBM style
    { repo = "AlexvZyl/nordic.nvim",             name = "nordic" },    -- Better than original Nord
    { repo = "vague-theme/vague.nvim",           name = "vague" },     -- Muted & moody
    { repo = "casedami/neomodern.nvim",          name = "neomodern" }, -- 5-in-1 theme collection
}

local plugins = {}
local themery_names = {}

for _, theme in ipairs(themes) do
    table.insert(plugins, { theme.repo, name = theme.name })
    table.insert(themery_names, theme.name)
end

table.insert(plugins, {
    "zaldih/themery.nvim",
    lazy = false,
    config = function()
        require("themery").setup({
            themes = themery_names,
            livePreview = true,
        })
    end,
    keys = {
        { "<leader>th", "<cmd>Themery<cr>", desc = "Theme Switcher" },
    },
})

return plugins
