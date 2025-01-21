return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		telescope.setup({
			defaults = {
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous,
						["<C-j>"] = actions.move_selection_next,
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					},
				},
			},
		})

		telescope.load_extension("fzf")
		vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
		vim.keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Find recent files" })
		vim.keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Search in files" })
		vim.keymap.set(
			"n",
			"<leader>fc",
			"<cmd>Telescope command_history<cr>",
			{ desc = "Search through command history." }
		)

		-- search only git tracked files
		-- ignores stuff like node_modules, etc.
		vim.keymap.set("n", "<leader>gf", "<cmd>Telescope git_files<cr>", { desc = "Find only git files." })
		vim.keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "Search through git commits." })
	end,
}
