return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        build = ":TSUpdate",
        config = function()
            local treesitter = require("nvim-treesitter.configs")
            treesitter.setup({
                highlight = {
                    enable = true,
                },
                indent = { enable = true },
                autotag = {
                    enable = true,
                },
                ensure_installed = {
                    "javascript",
                    "typescript",
                    "tsx",
                    "rust",
                    "dockerfile",
                },
                modules = {},
                auto_install = true,
                sync_install = true,
                ignore_install = {},
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<C-space>",
                        node_incremental = "<C-space>",
                        scope_incremental = false,
                        node_decremental = "<bs>",
                    },
                },
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        init = function()
            -- Disable entire built-in ftplugin mappings to avoid conflicts.
            -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
            vim.g.no_plugin_maps = true

            -- Or, disable per filetype (add as you like)
            -- vim.g.no_python_maps = true
            -- vim.g.no_ruby_maps = true
            -- vim.g.no_rust_maps = true
            -- vim.g.no_go_maps = true
        end,
        config = function()
            -- put your config here
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        opts = {
            enable_close = true,         -- Auto close tags
            enable_rename = true,        -- Auto rename pairs of tags
            enable_close_on_slash = true -- Auto close on trailing </
        },
    }
}
