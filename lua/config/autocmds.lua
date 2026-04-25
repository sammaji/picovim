vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		-- i use neovim to browse man pages
		for _, arg in ipairs(vim.v.argv) do
			if arg == "+Man!" then
				return
			end
		end
	end,
})
