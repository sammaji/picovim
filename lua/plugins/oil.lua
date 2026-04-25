return {
	"stevearc/oil.nvim",
	---@module 'oil'

	---@type oil.SetupOpts
	opts = {
		default_file_explorer = true,
		delete_to_trash = true,
		skip_confirm_for_simple_edits = true,

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
