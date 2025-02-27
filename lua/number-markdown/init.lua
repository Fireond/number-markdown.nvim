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

local function generate_number(true_level, counters)
	if true_level < 1 then
		return ""
	end

	while #counters < true_level do
		table.insert(counters, 0)
	end

	for i = true_level + 1, #counters do
		counters[i] = 0
	end

	counters[true_level] = counters[true_level] + 1

	local number = {}
	for i = 1, true_level do
		table.insert(number, counters[i])
	end

	return table.concat(number, ".") .. " "
end

local function update_headers(bufnr, start_level)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local counters = {}
	local new_lines = {}

	local set_counter = false
	local set_start_level = false
	local next_counter = 0

	for _, line in ipairs(lines) do
		local header_prefix = line:match("^(#+)%s+")
		local set_counter_value = tonumber(line:match("^%s*<!%-%-%s*set%s*counter%s*=%s*(%d+)%s*%-%->%s*$"))
		local set_start_level_value = tonumber(line:match("^%s*<!%-%-%s*set%s*start_level%s*=%s*(%d+)%s*%-%->%s*$"))

		if not set_start_level and set_start_level_value then
			start_level = set_start_level_value
			set_start_level = true
		end

		if not set_counter and set_counter_value then
			next_counter = set_counter_value
			set_counter = true
		end

		if header_prefix then
			local true_level = #header_prefix - start_level + 1
			local existing_number, text = line:match("^#+%s+(%d[%d%.]*)%s+(.*)$")

			if not existing_number then
				text = line:match("^#+%s+(.*)$")
			end

			if set_counter then
				counters[true_level] = next_counter - 1
				set_counter = false
			end

			local number_str = generate_number(true_level, counters)
			local new_line = header_prefix .. " " .. number_str .. (text or "")
			table.insert(new_lines, new_line)
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
