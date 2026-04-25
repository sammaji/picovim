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
				-- a lot of the times i find myself searching a git ignored file
				local ignore_globs = {
					"!**/.git/*",
					"!**/node_modules/*",
					"!**/.next/*",
					"!**/.turbo/*",
					"!**/target/*",
					"!**/venv/*",
					"!**/.venv/*",
					"!**/__pycache__/*",
					"!**/build/*",
					"!**/dist/*",
					"!**/vendor/*",
				}

				local find_command = { "rg", "--files" }

				for _, pattern in ipairs(ignore_globs) do
					table.insert(find_command, "--glob")
					table.insert(find_command, pattern)
				end

				require("telescope.builtin").find_files({
					path_display = { "truncate" },
					prompt_title = "Find files (incl. hidden, excl. .git)",
					find_command = find_command,
				})
			end,
			desc = "Find files (incl. hidden, excl. .git)",
		},
		{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Find recent files" },
		{ "<leader>fs", "<cmd>Telescope live_grep<cr>", desc = "Search in files (incl. hidden, excl. .git)" },
		{
			"<leader>fk",
			function()
				require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end,
			desc = "Find in a file",
		},
		{
			"<leader>fb",
			function()
				require("telescope.builtin").buffers({ path_display = { "truncate" }, prompt_title = "Buffers" })
			end,
			desc = "Search through buffers",
		},
		{
			"<leader>fcc",
			"<cmd>%y+<cr>",
			desc = "Copies the content of a buffer to the system clipboard.",
		},
		{
			"<leader>fcp",
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
			"<leader>fof",
			function()
				-- try to get the path
				-- if it's a directory (like in Oil), use it.
				-- if it's a file, get the parent directory.
				local raw_path = vim.api.nvim_buf_get_name(0)
				local clean_path = raw_path:gsub("^%w+://", "")
				if clean_path == "" then
					clean_path = vim.fn.getcwd()
				elseif vim.fn.isdirectory(clean_path) == 0 then
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
		{
			"<leader>fog",
			function()
				local file_path = vim.fn.expand("%:.")
				local line_num = vim.api.nvim_win_get_cursor(0)[1]
				local remote = vim.fn.systemlist("git config --get remote.origin.url")[1]
				if not remote or remote == "" then
					print("No git remote found")
					return
				end

				remote = remote
					:gsub("git@github.com:", "https://github.com/")
					:gsub("%.git$", "")
					:gsub("git://github.com/", "https://github.com/")

				-- detect the trunk branch (main, master, or custom)
				local trunk = vim.fn.systemlist("git symbolic-ref refs/remotes/origin/HEAD --short")[1]
				if trunk then
					trunk = trunk:gsub("origin/", "")
				else
					-- fallback: check local branches if origin/HEAD isn't set
					local branches = vim.fn.systemlist("git branch --list main master")
					trunk = #branches > 0 and branches[1]:gsub("%s*%*%s*", "") or "main"
				end

				local url = string.format("%s/blob/%s/%s#L%d", remote, trunk, file_path, line_num)
				if vim.fn.has("mac") == 1 then
					vim.fn.jobstart({ "open", url })
				elseif vim.fn.has("unix") == 1 then
					vim.fn.jobstart({ "xdg-open", url })
				else
					vim.ui.open(url) -- Neovim 0.10+ native fallback
				end
				print("Opened: " .. url)
			end,
			desc = "Find only git files.",
		},
		{ "<leader>fc", "<cmd>Telescope command_history<cr>", desc = "Search through command history." },
		{ "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Find only git files." },
		{ "<leader>fgc", "<cmd>Telescope git_commits<cr>", desc = "Search through git commits." },
		{
			"<leader>fgl",
			function()
				local line = vim.api.nvim_win_get_cursor(0)[1]
				local rel_file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
				local hashes = vim.fn.systemlist(
					string.format(
						"git log --format=%%H -L %d,%d:%s 2>/dev/null | grep -E '^[0-9a-f]{40}$'",
						line,
						line,
						rel_file
					)
				)
				if #hashes == 0 then
					vim.notify("No commits found for line " .. line, vim.log.levels.WARN)
					return
				end
				local git_command = vim.list_extend({ "git", "log", "--pretty=format:%H %D %s", "--no-walk" }, hashes)
				require("telescope.builtin").git_commits({ git_command = git_command })
			end,
			desc = "Search through commits that changed the current line.",
		},
		{ "<leader>fgf", "<cmd>Telescope git_status<cr>", desc = "Find only changed files." },
		{
			"<leader>fgs",
			function()
				local builtin = require("telescope.builtin")
				local git_cmd = "git ls-files --modified --others --exclude-standard --deduplicate"
				local changed_dirs = vim.fn.systemlist(git_cmd)
				if #changed_dirs == 0 then
					Snacks.notifier.notify("No changes found to search.", "warn")
					return
				end
				builtin.live_grep({
					search_dirs = changed_dirs,
					prompt_title = "Grep in Changed Files",
				})
			end,
			desc = "Search through changed files.",
		},
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
		{ "<leader>fm", "<cmd>MarkdownPreviewToggle<cr>", desc = "Open markdown preview in browser" },

		-- diff options (x for "diff")
		{ "<leader>xd", "<cmd>DiffviewOpen<cr>", desc = "Open diff view" },
		{ "<leader>xf", "<cmd>DiffviewFileHistory %<cr>", desc = "Open file history in a quickfix list" },
		{ "<leader>xx", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
	},
}
