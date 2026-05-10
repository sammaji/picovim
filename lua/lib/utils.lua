local M = {}

function M.tableMerge(t1, t2)
	for k, v in pairs(t2) do
		if type(v) == "table" then
			if type(t1[k] or false) == "table" then
				M.tableMerge(t1[k] or {}, t2[k] or {})
			else
				t1[k] = v
			end
		else
			t1[k] = v
		end
	end
	return t1
end

-- adds description to a table
-- useful when settings keybindings
function M.desc(table, s)
	table.desc = s
	return table
end

-- returns the relative path of the current file
-- handles trimming for some special buffers like oil://
-- and return true if its a special buffer
--
-- example:
-- /Users/levi/code/oil/oil.lua (normal file buffer) => (code/oil/oil.lua, false)
-- oil://Users/levi/code/oil/oil.lua (oil buffer) => (code/oil/oil.lua, true)
function M.get_relative_path()
	local pattern = "^oil://"
	local buf_name = vim.api.nvim_buf_get_name(0)
	local is_special = buf_name:match(pattern) ~= nil
	local clean_path = buf_name:gsub(pattern, ""):gsub("/$", "")
	local rel_path = vim.fn.fnamemodify(clean_path, ":.")
	return rel_path, is_special
end

return M
