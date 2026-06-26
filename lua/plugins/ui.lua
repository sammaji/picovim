return {
	{
		"sontungexpt/stcursorword",
		event = "VeryLazy",
		opts = {
			max_word_length = 100, -- if cursorword length > max_word_length then not highlight
			min_word_length = 2, -- if cursorword length < min_word_length then not highlight
			excluded = {
				filetypes = {
					"TelescopePrompt",
				},
				-- the pattern to match with the file path
				patterns = {
					"%.png$",
					"%.jpg$",
					"%.jpeg$",
					"%.pdf$",
					"%.zip$",
					"%.tar$",
					"%.tar%.gz$",
					"%.tar%.xz$",
					"%.tar%.bz2$",
					"%.rar$",
					"%.7z$",
					"%.mp3$",
					"%.mp4$",
				},
			},
			highlight = {
				underline = true,
				fg = nil,
				bg = nil,
			},
		},
	},
	{
		"dlyongemallo/diffview.nvim",
		dependencies = "nvim-tree/nvim-web-devicons", -- optional, for file icons
		opts = function()
			local diffview_actions = require("diffview.actions")
			return {
				enhanced_diff_hl = true, -- Better highlights for structural changes
				use_icons = true,
				view = {
					merge_tool = {
						layout = "diff3_mixed",
						disable_diagnostics = true,
					},
				},
				file_panel = {
					listing_style = "tree",
					tree_options = {
						flatten_dirs = true,
						folder_statuses = "only_folded",
					},
					win_config = {
						position = "left",
						width = 35,
					},
				},
				keymaps = {
					view = {
						{ "n", "<leader>xco", diffview_actions.conflict_choose("ours") },
						{ "n", "<leader>xct", diffview_actions.conflict_choose("theirs") },
						{ "n", "<leader>xcb", diffview_actions.conflict_choose("base") },
						{ "n", "<leader>xca", diffview_actions.conflict_choose("all") },
						{ "n", "<leader>xcn", diffview_actions.conflict_choose("none") },
						{ "n", "gl", diffview_actions.prev_conflict() },
						{ "n", "gh", diffview_actions.next_conflict() },
					},
					file_panel = {},
				},
			}
		end,
	},
	-- === markdown extensions === --
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown", "mdx" },
		build = "npm install",
		init = function()
			vim.g.mkdp_auto_start = 0 -- Don't open browser immediately
			vim.g.mkdp_auto_close = 1 -- Close browser when buffer is closed
			vim.g.mkdp_refresh_slow = 0 -- Refresh as you type (0 = real-time)
			vim.g.mkdp_theme = "dark" -- Use dark mode in the browser
			vim.g.mkdp_browser = ""
			vim.g.mkdp_port = "8888"
			vim.fn["mkdp#util#install"]()
		end,
	},
	-- === fzf === --
	{
		"junegunn/fzf.vim",
		dependencies = { "junegunn/fzf" },
	},
}
