return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
		"3rd/image.nvim",
		{
			"s1n7ax/nvim-window-picker",
			version = "2.*",
			config = function()
				require("window-picker").setup({
					filter_rules = {
						include_current_win = false,
						autoselect_one = true,
						bo = {
							filetype = { "neo-tree", "neo-tree-popup", "notify" },
							buftype = { "terminal", "quickfix" },
						},
					},
				})
			end,
		},
	},
	config = function()
		require("neo-tree").setup({
			close_if_last_window = true, -- close if only Neo-tree is left
			popup_border_style = "rounded",
			enable_git_status = true,
			enable_diagnostics = true,

			filesystem = {
				follow_current_file = {
					enabled = true, -- tree expands to the active file
					leave_dirs_open = false, -- closes other dirs to save space
				},
				use_libuv_file_watcher = true, -- os level file watcher
				filtered_items = {
					visible = true, -- show hidden files but faded
					hide_dotfiles = false,
					hide_gitignored = false,
				},
			},

			default_component_configs = {
				indent = {
					with_expanders = true,
					expander_collapsed = "",
					expander_expanded = "",
				},
				git_status = {
					symbols = {
						unstaged = "󰄱",
						staged = "",
						conflict = "",
					},
				},
			},

			window = {
				width = 35, -- slightly wider for deep nested paths
				mappings = {
					["<space>"] = "none", -- unbind space so it doesn't conflict with leader
					["l"] = "open",
					["h"] = "close_node",
					["p"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
				},
			},
		})

		vim.keymap.set("n", "\\", "<cmd>Neotree reveal<cr>", { desc = "Neo-tree Reveal" })
	end,
}
