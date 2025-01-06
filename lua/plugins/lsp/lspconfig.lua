local function organize_imports()
    local params = {
        command = "_typescript.organizeImports",
        arguments = { vim.api.nvim_buf_get_name(0) },
        title = "TSOrganizeImports"
    }
    vim.lsp.buf.execute_command(params)
end

local utils = require("lib.utils")

return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/neodev.nvim",                   opts = {} },
    },
    config = function()
        local lspconfig = require("lspconfig")
        local mason_lspconfig = require("mason-lspconfig")
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        local keymap = vim.keymap

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
                -- Buffer local mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                local opts = { buffer = ev.buf, silent = true }

                -- set keybinds
                keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", utils.desc(opts, "Show LSP references"))        -- show definition, references
                keymap.set("n", "gde", vim.lsp.buf.declaration, utils.desc(opts, "Go to declaration"))                     -- go to declaration
                keymap.set("n", "gdf", "<cmd>Telescope lsp_definitions<CR>", utils.desc(opts, "Show LSP definitions"))     -- show lsp definitions
                keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>",
                    utils.desc(opts, "Show LSP implementations"))                                                          -- show lsp implementations
                keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>",
                    utils.desc(opts, "Show LSP type definitions"))                                                         -- show lsp type definitions
                keymap.set({ "n", "v" }, "gca", vim.lsp.buf.code_action, utils.desc(opts, "See available code actions"))   -- see available code actions, in visual mode will apply to selection
                keymap.set("n", "grn", vim.lsp.buf.rename, utils.desc(opts, "Smart rename"))                               -- smart rename
                keymap.set("n", "gea", "<cmd>Telescope diagnostics bufnr=0<CR>",
                    utils.desc(opts, "Show buffer diagnostics"))                                                           -- show  diagnostics for file
                keymap.set("n", "gE", vim.diagnostic.open_float,
                    utils.desc(opts, "Show line diagnostics (error, warn etc.)"))                                          -- show diagnostics for line
                keymap.set("n", "gl", vim.diagnostic.goto_prev, utils.desc(opts, "Go to previous diagnostic"))             -- jump to previous diagnostic in buffer
                keymap.set("n", "gh", vim.diagnostic.goto_next, utils.desc(opts, "Go to next diagnostic"))                 -- jump to next diagnostic in buffer
                keymap.set("n", "g\\", vim.lsp.buf.hover, utils.desc(opts, "Show documentation for what is under cursor")) -- show documentation for what is under cursor
                keymap.set("n", "gq", ":LspRestart<CR>", utils.desc(opts, "Restart LSP"))                                  -- mapping to restart lsp if necessary
            end,
        })

        local capabilities = cmp_nvim_lsp.default_capabilities()

        local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        mason_lspconfig.setup_handlers({
            -- default handler for installed servers
            function(server_name)
                -- ignore rust lsp, as rustacean is being used.
                if (server_name == "rust_analyzer") then return end
                lspconfig[server_name].setup({
                    capabilities = capabilities,
                })
            end,

            -- lua
            ["lua_ls"] = function()
                lspconfig["lua_ls"].setup({
                    filetypes = { "lua" },
                    capabilities = capabilities,
                    settings = {
                        Lua = {
                            -- make the language server recognize "vim" global
                            diagnostics = {
                                globals = { "vim" },
                            },
                            completion = {
                                callSnippet = "Replace",
                            },
                        },
                    },
                })
            end,

            -- web
            -- ts/tsx/js/jsx
            ["tsserver"] = function()
                lspconfig["tsserver"].setup({
                    filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
                    cmd = { "typescript-language-server", "--stdio" },
                    commands = {
                        TSOrganizeImports = {
                            organize_imports,
                            description = "Organize Imports"
                        }
                    }
                })
            end,

        })
    end,
}
