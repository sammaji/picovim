return {
    "romgrk/barbar.nvim",
    dependencies = {
        "lewis6991/gitsigns.nvim",     -- OPTIONAL: for git status
        "nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
    },
    lazy = false,
    init = function()
        vim.g.barbar_auto_setup = false
    end,
    opts = {
        insert_at_start = true,
        icons = {
            button = "",
            gitsigns = {
                added = { enabled = true, icon = "+" },
                changed = { enabled = true, icon = "~" },
                deleted = { enabled = true, icon = "-" },
            },
            modified = { button = "●" },
            pinned = { button = "", filename = true },
        },
    },
    version = "^1.0.0",
    keys = {
        { "<M-1>",      "<cmd>BufferGoto 1<cr>",              mode = "n", desc = "Goto tab 1" },
        { "<M-2>",      "<cmd>BufferGoto 2<cr>",              mode = "n", desc = "Goto tab 2" },
        { "<M-3>",      "<cmd>BufferGoto 3<cr>",              mode = "n", desc = "Goto tab 3" },
        { "<M-4>",      "<cmd>BufferGoto 4<cr>",              mode = "n", desc = "Goto tab 4" },
        { "<M-5>",      "<cmd>BufferGoto 5<cr>",              mode = "n", desc = "Goto tab 5" },
        { "<M-6>",      "<cmd>BufferGoto 6<cr>",              mode = "n", desc = "Goto tab 6" },
        { "<M-7>",      "<cmd>BufferGoto 7<cr>",              mode = "n", desc = "Goto tab 7" },
        { "<M-8>",      "<cmd>BufferGoto 8<cr>",              mode = "n", desc = "Goto tab 8" },
        { "<M-9>",      "<cmd>BufferGoto 9<cr>",              mode = "n", desc = "Goto tab 9" },
        { "<C-w>h",     "<cmd>BufferPrevious<cr>",            mode = "n", desc = "Goto previous buffer" },
        { "<C-w>l",     "<cmd>BufferNext<cr>",                mode = "n", desc = "Goto next buffer" },
        { "<C-w>x",     "<cmd>BufferClose<cr>",               mode = "n", desc = "Close current tab" },
        { "<C-w>u",     "<cmd>BufferRestore<cr>",             mode = "n", desc = "Restore tabs" },
        { "<C-w>d",     "<cmd>BufferCloseAllButCurrent<cr>",  mode = "n", desc = "Close all but current tab" },
        { "<leader>bb", "<cmd>BufferOrderByBufferNumber<cr>", mode = "n", desc = "Order buffer by buffer number" },
        { "<leader>bn", "<cmd>BufferOrderByName<cr>",         mode = "n", desc = "Order buffer by name" },
        { "<leader>bd", "<cmd>BufferOrderByDirectory<cr>",    mode = "n", desc = "Order buffer by directory" },
        { "<leader>bl", "<cmd>BufferOrderByLanguage<cr>",     mode = "n", desc = "Order buffer by language" },
        { "<leader>bw", "<cmd>BufferOrderByWindowNumber<cr>", mode = "n", desc = "Order buffer by window number" },
    },
}
