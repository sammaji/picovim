local utils = require("lib.utils")

return {
    {
        "saghen/blink.cmp",
        dependencies = { "rafamadriz/friendly-snippets" },
        version = "*",
        opts = {
            keymap = {
                preset = "none",
                ["<Up>"] = { "select_prev", "fallback" },
                ["<Down>"] = { "select_next", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
                ["<C-j>"] = { "select_next", "fallback" },

                -- accept suggestion
                ["<CR>"] = { "accept", "fallback" },
                ["<Tab>"] = { "snippet_forward", "fallback" },
                ["<S-Tab>"] = { "snippet_backward", "fallback" },

                -- documentation
                ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
            },

            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = "mono",
            },

            sources = { default = { "lsp", "path", "snippets", "buffer" } },

            completion = {
                accept = { auto_brackets = { enabled = true } }, -- auto-adds () to functions
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 200,
                    window = { focusable = true },
                },
                -- shows the suggestion as virtual text
                ghost_text = { enabled = true },
            },

            signature = { enabled = true, auto_show = true, window = { border = "rounded" }, },
        },
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "saghen/blink.cmp",
            { "antosha417/nvim-lsp-file-operations", config = true },
            { "folke/lazydev.nvim",                  opts = {} },
        },
        config = function()
            local lspconfig = require("lspconfig")
            local mason_lspconfig_status, mason_lspconfig = pcall(require, "mason-lspconfig")
            local capabilities = require("blink.cmp").get_lsp_capabilities()

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    -- Buffer local mappings.
                    -- See `:help vim.lsp.*` for documentation on any of the below functions
                    local opts = { buffer = ev.buf, silent = true }

                    -- set keybinds
                    vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>",
                        utils.desc(opts, "Show LSP references (every single place where this symbol is being used)"))      -- show definition, references
                    vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>",
                        utils.desc(opts, "Show LSP definitions (place where a variable, function, or class was created)")) -- show lsp definitions
                    vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>",
                        utils.desc(opts, "Show LSP implementations (places where classes / traits are implemented)"))      -- show lsp implementations
                    vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>",
                        utils.desc(opts, "Show LSP type definitions"))                                                     -- show lsp type definitions
                    vim.keymap.set({ "n", "v" }, "gca", vim.lsp.buf.code_action,
                        utils.desc(opts, "See available code actions"))                                                    -- see available code actions, in visual mode will apply to selection
                    vim.keymap.set("n", "grn", vim.lsp.buf.rename, utils.desc(opts, "Smart rename"))                       -- smart rename

                    vim.keymap.set("n", "ge", vim.diagnostic.open_float,
                        utils.desc(opts, "Show diagnostics for line"))
                    vim.keymap.set("n", "gE", "<cmd>Telescope diagnostics bufnr=0<CR>",
                        utils.desc(opts, "Show all diagnostics for current buffer"))

                    vim.keymap.set("n", "gl", function() vim.diagnostic.jump({ count = -1, float = true }) end,
                        utils.desc(opts, "Go to previous diagnostic"))
                    vim.keymap.set("n", "gh", function() vim.diagnostic.jump({ count = 1, float = true }) end,
                        utils.desc(opts, "Go to next diagnostic"))

                    vim.keymap.set("n", "g\\", vim.lsp.buf.hover,
                        utils.desc(opts, "Show documentation"))                                       -- show documentation for what is under cursor
                    vim.keymap.set("n", "gq", "<cmd>LspRestart<CR>", utils.desc(opts, "Restart LSP")) -- mapping to restart lsp if necessary
                end,
            })

            -- suppress request cancellation error for active lsp like rust_analyzer or ts_ls
            for _, method in ipairs({ 'textDocument/diagnostic', 'workspace/diagnostic' }) do
                local default_diagnostic_handler = vim.lsp.handlers[method]
                vim.lsp.handlers[method] = function(err, result, context, config)
                    if err ~= nil and err.code == -32802 then
                        return
                    end
                    return default_diagnostic_handler(err, result, context, config)
                end
            end

            local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
            end

            if mason_lspconfig_status and mason_lspconfig.setup_handlers ~= nil then
                mason_lspconfig.setup_handlers({
                    -- default handler for installed servers
                    function(server_name)
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
                    ["ts_ls"] = function()
                        lspconfig["ts_ls"].setup({
                            filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact", "javascript.jsx" },
                            capabilities = capabilities,
                            cmd = { "typescript-language-server", "--stdio" },
                            settings = {
                                typescript = {
                                    inlayHints = {
                                        includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
                                        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                                        includeInlayFunctionParameterTypeHints = true,
                                        includeInlayVariableTypeHints = true,
                                        includeInlayPropertyDeclarationTypeHints = true,
                                        includeInlayFunctionLikeReturnTypeHints = true,
                                        includeInlayEnumMemberValueHints = true,
                                    },
                                },
                                javascript = {
                                    inlayHints = {
                                        includeInlayParameterNameHints = "all",
                                        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                                        includeInlayFunctionParameterTypeHints = true,
                                        includeInlayVariableTypeHints = true,
                                        includeInlayPropertyDeclarationTypeHints = true,
                                        includeInlayFunctionLikeReturnTypeHints = true,
                                        includeInlayEnumMemberValueHints = true,
                                    },
                                },
                            }
                        })
                    end,

                    -- tailwindcss
                    ["tailwindcss"] = function()
                        lspconfig["tailwindcss"].setup({
                            capabilities = capabilities,
                            filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
                            settings = {
                                tailwindCSS = {
                                    experimental = {
                                        classRegex = {
                                            { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*)\"'" },
                                            { "cx\\(([^)]*)\\)",  "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                                        },
                                    },
                                },
                            },
                        })
                    end,

                    -- rust
                    ["rust_analyzer"] = function()
                        lspconfig["rust_analyzer"].setup({
                            cmd = { "rust-analyzer" },
                            capabilities = capabilities,
                            filetypes = { "rust" },
                            root_dir = function(fname)
                                return lspconfig.util.root_pattern("Cargo.toml")(fname) or vim.fs.dirname(fname)
                            end,
                            settings = {
                                ["rust-analyzer"] = {
                                    checkOnSave = {
                                        command = "clippy"
                                    },
                                    procMacro = {
                                        enable = true,
                                        ["async-trait"] = { "async_trait" },
                                        ["napi-derive"] = { "napi" },
                                        ["async-recursion"] = { "async_recursion" },
                                    },
                                    diagnostics = {
                                        enable = true,
                                    },
                                    cargo = {
                                        allFeatures = true,
                                        loadOutDirsFromCheck = true,
                                        buildScripts = {
                                            enable = true,
                                        },
                                    },
                                    hover = {
                                        actions = {
                                            references = { enable = true },
                                        },
                                    },
                                    lens = {
                                        enable = true,
                                    },
                                }
                            }
                        })
                    end,

                    -- golang
                    ["gopls"] = function()
                        lspconfig["gopls"].setup({
                            capabilities = capabilities,
                            settings = {
                                gopls = {
                                    staticcheck = true,
                                    -- show directory filters to speed up large monorepos
                                    directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
                                    analyses = {
                                        unusedparams = true,   -- warn about unused function parameters
                                        shadow = true,         -- warn about variable shadowing
                                        unusedwrite = true,    -- warn about unused writes
                                        fieldalignment = true, -- suggest better struct field alignment for memory
                                    },
                                    hints = {
                                        assignVariableTypes = true,
                                        compositeLiteralFields = true,
                                        compositeLiteralTypes = true,
                                        constantValues = true,
                                        functionTypeParameters = true,
                                        parameterNames = true,
                                        rangeVariableTypes = true,
                                    },
                                    buildFlags = { "-tags=unit,integration" },
                                    completeUnimported = true, -- suggest completions from unimported packages
                                    usePlaceholders = true,    -- add placeholders for function arguments
                                },
                            },
                        })
                    end,

                    -- python lsp configs for heavy python type linting
                    -- you will need this if you are mainting python libraries
                    -- disable workspace diagnostics if this setup impacts performance
                    ["pyright"] = function()
                        lspconfig["pyright"].setup({
                            capabilities = capabilities,
                            settings = {
                                python = {
                                    analysis = {
                                        typeCheckingMode = "strict",
                                        autoSearchPaths = true,
                                        useLibraryCodeForTypes = true,
                                        -- check all files in the project, not just open ones
                                        diagnosticMode = "workspace",
                                        -- show hints for function parameters and return types
                                        inlayHints = {
                                            variableTypes = true,
                                            functionReturnTypes = true,
                                        },
                                    },
                                },
                            },
                        })
                    end,

                    ["ruff"] = function()
                        lspconfig["ruff"].setup({
                            capabilities = capabilities,
                            on_attach = function(client)
                                -- disable hover in favor of Pyright
                                client.server_capabilities.hoverProvider = false
                            end,
                        })
                    end,
                })
            end

            vim.diagnostic.config({
                virtual_text = { prefix = "●" },
                update_in_insert = true,
                underline = true,
                severity_sort = true,
                float = {
                    focusable = false,
                    style = "minimal",
                    border = "rounded",
                    source = "if_many",
                    header = "",
                    prefix = "",
                },
            })
        end,
    },
    {
        "williamboman/mason.nvim",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
        },
        config = function()
            local mason = require("mason")
            local mason_lspconfig = require("mason-lspconfig")
            local mason_tool_installer = require("mason-tool-installer")

            mason.setup({})
            mason_lspconfig.setup({
                ensure_installed = {
                    "rust_analyzer",
                    "ts_ls",
                    "tailwindcss",
                    "prismals",
                    "eslint"
                },
            })

            mason_tool_installer.setup({
                ensure_installed = {
                    "prettierd",
                    "stylua",    -- Lua
                    "goimports", -- Go imports
                    "gofumpt",   -- Go format
                    "ruff",      -- Python (Ruff handles both linting and formatting)
                },
            })
        end,
    },
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            formatters_by_ft = {
                javascript = { "prettierd" },
                typescript = { "prettierd" },
                javascriptreact = { "prettierd" },
                typescriptreact = { "prettierd" },
                css = { "prettierd" },
                html = { "prettierd" },
                json = { "prettierd" },
                yaml = { "prettierd" },
                lua = { "stylua" },
                python = { "ruff_organize_imports", "ruff_format" },
                go = { "goimports", "gofumpt" },
                rust = { "rustfmt" },
            },
            format_on_save = {
                lsp_fallback = true,
                async = false,
                timeout_ms = 1000,
            },
        },
    }
}
