return {
    {
        'rmagatti/auto-session',
        lazy = false,
        opts = {
            log_level = 'warn',
        },
        setup = function()
            require('auto-session').setup()
            vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
        end,
    },
    {
        "tpope/vim-fugitive",
    },
    {
        "tpope/vim-surround",
    }
}
