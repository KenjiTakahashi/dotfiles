local M = {}

local config = {
	callback = nil,
}

M.config = config

function M.setup(config)
	M.config = vim.tbl_deep_extend("force", M.config, config or {})

	local fp = vim.api.nvim_buf_get_name(0)
	local dir = vim.fs.dirname(fp)
	local root = vim.fs.find({ "go.mod", ".git" }, {
		upward = true,
		stop = vim.loop.os_homedir(),
		path = dir,
	})[1]
	if root == nil then
		-- FIXME Ugly, refactor
		if M.config.callback ~= nil then
			M.config.callback(type, module)
		end
		return
	end
	local root_base = vim.fs.basename(root)
	local root_dir = vim.fs.dirname(root)

	local type, module
	if root_base ~= ".git" then
		local c = vim.secure.read(root)
		-- XXX Doesn't work for go.mod files even w/ both fn and contents
		local ft = vim.filetype.match({
			filename = root_base,
			-- contents = c,
			-- contents = vim.split(c, "\n"),
			-- contents = XXX Needs table of lines?!
		})
		if ft == nil then
			if root_base == "go.mod" then ft = "gomod"
			end
		end
		local lt = vim.treesitter.get_string_parser(c, ft)
		local st = lt:parse()
		local r = st[1]:root()
		local q = vim.treesitter.query.parse(ft, [[
			(module_directive
				(module_path) @mp)
		]])
		local r = q:iter_captures(r, c)
		local _, first = r()

		module = vim.treesitter.get_node_text(first, c)

		if ft == "gomod" then type = "go"
		elseif root_base == "package.json" then type = "js"
		end
	end

	vim.api.nvim_set_current_dir(root_dir)

	if M.config.callback ~= nil then
		M.config.callback(type, module)
	end
end

return M
