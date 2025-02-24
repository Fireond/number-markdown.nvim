local M = {
	_auto_update_enabled = nil,
}

local config = {
	start_level = 2,
	auto_update = true,
}

function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})

	-- Create commands
	vim.api.nvim_create_user_command("MDNumberHeaders", function()
		M.number_headers()
	end, {})
	vim.api.nvim_create_user_command("MDClearNumbers", function()
		M.clear_numbers()
	end, {})
	vim.api.nvim_create_user_command("MDToggleAutoUpdate", function()
		M.toggle_auto_update()
	end, {})

	-- Auto-update on save if enabled
	vim.api.nvim_create_autocmd("BufWritePre", {
		pattern = "*.md",
		callback = function()
			if M.get_auto_update_status() then
				M.number_headers()
			end
		end,
	})
end

local function generate_number(current_level, counters, start_level)
	if current_level < start_level then
		return ""
	end

	local level_index = current_level - start_level + 1
	while #counters < level_index do
		table.insert(counters, 0)
	end

	for i = level_index + 1, #counters do
		counters[i] = 0
	end

	counters[level_index] = counters[level_index] + 1

	local number = {}
	for i = 1, level_index do
		table.insert(number, counters[i])
	end

	return table.concat(number, ".") .. " "
end

local function update_headers(bufnr, start_level)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local counters = {}
	local last_level = 0
	local new_lines = {}

	for _, line in ipairs(lines) do
		local header_prefix = line:match("^(#+)%s+")

		if header_prefix then
			local current_level = #header_prefix
			local existing_number, text = line:match("^#+%s+(%d[%d%.]*)%s+(.*)$")

			if not existing_number then
				text = line:match("^#+%s+(.*)$")
			end

			local number_str = generate_number(current_level, counters, start_level)
			local new_line = header_prefix .. " " .. number_str .. (text or "")
			table.insert(new_lines, new_line)

			last_level = current_level
		else
			table.insert(new_lines, line)
		end
	end

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
end

function M.number_headers()
	local bufnr = vim.api.nvim_get_current_buf()
	update_headers(bufnr, config.start_level)
end

function M.clear_numbers()
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local new_lines = {}

	for _, line in ipairs(lines) do
		local header_prefix, content = line:match("^(#+)%s+(.*)$")
		if header_prefix and content then
			local cleaned_content = content:gsub("^%d[%.%d]*%s+", "")
			table.insert(new_lines, header_prefix .. " " .. cleaned_content)
		else
			table.insert(new_lines, line)
		end
	end

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
end

function M.toggle_auto_update()
	M._auto_update_enabled = not M._auto_update_enabled
	vim.notify("Auto-update " .. (M._auto_update_enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end

function M.get_auto_update_status()
	if M._auto_update_enabled == nil then
		return type(config.auto_update) == "boolean" and config.auto_update
			or type(config.auto_update) == "function" and config.auto_update()
	else
		return M._auto_update_enabled
	end
end

return M
