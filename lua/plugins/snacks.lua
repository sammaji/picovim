-- @module 'snacks'
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		bigfile = { enabled = true },
		dashboard = { enabled = true, example = "github" },
		explorer = { enabled = true },
		indent = { enabled = true },
		input = { enabled = true },
		picker = { enabled = true },
		notifier = { enabled = true },
		quickfile = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = true },
		statuscolumn = { enabled = true },
		terminal = { enabled = true },
		words = { enabled = true },
	},
	keys = {
		-- buffer management
		{ "<leader>bh", "<cmd>:split<cr>", desc = "Split horizontally" },
		{ "<leader>bv", "<cmd>:vsplit<cr>", desc = "Split vertically" },

		-- finding stuff (mostly files)
		-- f for "find" or "file"
		{
			"<leader>ff",
			function()
				require("telescope.builtin").find_files({
					path_display = { "filename_first" },
					prompt_title = "Find files (incl. hidden, excl. .git)",
					find_command = {
						"rg",
						"--files",
						"--hidden",
						"--glob",
						"!**/.git/*",
					},
				})
			end,
			desc = "Find files (incl. hidden, excl. .git)",
		},
		{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Find recent files" },
		{ "<leader>fs", "<cmd>Telescope live_grep<cr>", desc = "Search in files" },
		{
			"<leader>fcp",
			"<cmd>%y+<cr>",
			desc = "Copies the content of a buffer to the system clipboard.",
		},
		{
			"<leader>frp",
			function()
				local path = vim.fn.expand("%:p")
				-- try git root, if that fails, use the project root
				local root = Snacks.git.get_root() or vim.fn.getcwd()
				-- remove the root from the path
				local relative_path = path:sub(#root + 2)
				-- copy to system clipboard
				vim.fn.setreg("+", relative_path)
				Snacks.notifier.notify("Copied relative path: " .. relative_path, "info")
			end,
			desc = "Copies the relative path of the file to the system clipboard.",
		},
		{
			"<leader>fo",
			function()
				-- try to get the path
				-- if it's a directory (like in Oil), use it.
				-- if it's a file, get the parent directory.
				local raw_path = vim.api.nvim_buf_get_name(0)
				local clean_path = raw_path:gsub("^%w+://", "")
				if clean_path == "" then
					-- fallback to project root if buffer is totally empty
					clean_path = vim.fn.getcwd()
				elseif vim.fn.isdirectory(clean_path) == 0 then
					-- tt's a file, get the directory
					clean_path = vim.fn.fnamemodify(clean_path, ":h")
				end
				-- os-specific opener logic
				local opener = vim.fn.has("mac") == 1 and "open"
					or (vim.fn.has("win32") == 1 or vim.fn.has("wsl") == 1) and "explorer.exe"
					or "xdg-open"

				vim.fn.jobstart({ opener, clean_path }, { detach = true })
				Snacks.notifier.notify("Opened: " .. clean_path, "info", { title = "File Manager" })
			end,
			desc = "Open folder in file manager (Files/Oil/CWD)",
		},
		{ "<leader>fc", "<cmd>Telescope command_history<cr>", desc = "Search through command history." },
		{ "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Find only git files." },
		{ "<leader>fgc", "<cmd>Telescope git_commits<cr>", desc = "Search through git commits." },
		{
			"<leader>fd",
			function()
				Snacks.picker.lsp_symbols()
			end,
			desc = "Search through LSP symbols",
		},
		{ "<leader>ft", "<cmd>Neotree toggle<cr>", desc = "Toggle file tree view" },

		-- terminal management
		{
			"<leader>tt",
			function()
				Snacks.terminal.toggle("zsh", { cwd = Snacks.git.get_root(), auto_close = true })
			end,
			desc = "Create a floating terminal",
		},
		{
			"<leader>tv",
			function()
				Snacks.terminal.toggle(
					"zsh",
					{ cwd = Snacks.git.get_root(), auto_close = true, win = { position = "right" } }
				)
			end,
			desc = "Create a vertical terminal",
		},
		{
			"<leader>tn",
			function()
				Snacks.terminal.toggle(
					"zsh",
					{ cwd = Snacks.git.get_root(), auto_close = true, win = { position = "right" } }
				)
			end,
			desc = "Create a nodejs REPL",
		},
		{
			"<leader>tdb",
			function()
				local env_file = Snacks.git.get_root() .. "/.env"
				local db_url = nil

				local f = io.open(env_file, "r")
				if f then
					local content = f:read("*all")
					f:close()

					db_url = content:match("DATABASE_URL=([^\n]+)")
						or content:match("DB_URL=([^\n]+)")
						or content:match("POSTGRES_URL=([^\n]+)")
						or content:match("POSTGRESQL_URL=([^\n]+)")
				end

				-- launch terminal if URL is found
				if db_url then
					db_url = db_url:gsub('"', ""):gsub("'", "")
					Snacks.terminal.toggle("psql " .. db_url, {
						cwd = Snacks.git.get_root(),
						win = {
							position = "right",
							width = 0.4,
						},
					})
				else
					Snacks.notifier.notify("No Database URL found in .env", "warn")
				end
			end,
			desc = "Toggle database shel (psql)",
		},

		-- diff options (x for "diff")
		{ "<leader>xd", "<cmd>DiffviewOpen<cr>", desc = "Open diff view" },
		{ "<leader>xf", "<cmd>DiffviewFileHistory %<cr>", desc = "Open file history in a quickfix list" },
		{ "<leader>xx", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
	},
}
