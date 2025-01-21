return {
	"sontungexpt/stcursorword",
	event = "VeryLazy",
	opts = {
		max_word_length = 100, -- if cursorword length > max_word_length then not highlight
		min_word_length = 2, -- if cursorword length < min_word_length then not highlight
		excluded = {
			filetypes = {
				"TelescopePrompt",
			},
			buftypes = {
				-- "nofile",
				-- "terminal",
			},
			patterns = { -- the pattern to match with the file path
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
}
