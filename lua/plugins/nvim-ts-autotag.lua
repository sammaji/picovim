return {
    "windwp/nvim-ts-autotag",
    ft = {
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
        "html"
    },
    opts = {
        enable_close = false,         -- Auto close tags
        enable_rename = true,         -- Auto rename pairs of tags
        enable_close_on_slash = false -- Auto close on trailing </
    }
}
