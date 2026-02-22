return {
    'stevearc/oil.nvim',
    ---@module 'oil'

    ---@type oil.SetupOpts
    opts = {
        view_options = {
            show_hidden = true,
        },
        float = {
            padding = 2,
        },
    },
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    lazy = false,
}
