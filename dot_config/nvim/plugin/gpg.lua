if vim.fn.executable("gpg") == 0 then
	return
end

local encrypted_file_pattern = "*.gpg"

local function run_gpg(arguments, input)
	local command = vim.list_extend({ "gpg", "--batch", "--quiet" }, arguments)
	return vim.system(command, { stdin = input }):wait()
end

local function report_gpg_failure(summary, result)
	vim.notify(summary .. "\n" .. vim.trim(result.stderr or ""), vim.log.levels.ERROR)
end

local function keep_plaintext_off_disk(buffer)
	vim.bo[buffer].swapfile = false
	vim.bo[buffer].undofile = false
	vim.o.shada = ""
end

local function replace_buffer_text_without_undo_entry(buffer, text)
	local lines = vim.split(text, "\n", { plain = true })
	if lines[#lines] == "" then
		table.remove(lines)
	end

	local undo_levels = vim.bo[buffer].undolevels
	vim.bo[buffer].undolevels = -1
	vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
	vim.bo[buffer].undolevels = undo_levels
	vim.bo[buffer].modified = false
end

local function detect_plaintext_filetype(buffer, encrypted_path)
	local plaintext_name = vim.fn.fnamemodify(encrypted_path, ":r")
	local filetype = vim.filetype.match({ filename = plaintext_name, buf = buffer })
	if filetype then
		vim.bo[buffer].filetype = filetype
	end
end

local function load_decrypted_file(event)
	local buffer, encrypted_path = event.buf, event.match
	keep_plaintext_off_disk(buffer)

	if vim.uv.fs_stat(encrypted_path) then
		local decryption = run_gpg({ "--decrypt", encrypted_path })
		vim.b[buffer].gpg_decryption_failed = decryption.code ~= 0
		if decryption.code ~= 0 then
			report_gpg_failure("gpg could not decrypt " .. encrypted_path, decryption)
			return
		end
		replace_buffer_text_without_undo_entry(buffer, decryption.stdout)
	end

	detect_plaintext_filetype(buffer, encrypted_path)
end

local function recipient_arguments(encrypted_path)
	local arguments = {}
	if vim.uv.fs_stat(encrypted_path) then
		local packets = run_gpg({ "--list-only", "--list-packets", encrypted_path }).stdout or ""
		for key_id in packets:gmatch(":pubkey enc packet:[^\n]* keyid (%x+)") do
			vim.list_extend(arguments, { "--recipient", key_id })
		end
	end
	if #arguments == 0 then
		return { "--default-recipient-self" }
	end
	return arguments
end

local function save_encrypted_file(event)
	local buffer = event.buf
	local encrypted_path = vim.uv.fs_realpath(event.match) or event.match

	if vim.b[buffer].gpg_decryption_failed then
		vim.notify(
			"Not writing " .. encrypted_path .. ": it was never decrypted into this buffer. Reload it with :edit",
			vim.log.levels.ERROR
		)
		return
	end

	local plaintext = table.concat(vim.api.nvim_buf_get_lines(buffer, 0, -1, false), "\n") .. "\n"
	local staged_path = encrypted_path .. ".tmp"
	local arguments = { "--yes", "--encrypt", "--output", staged_path }
	local encryption = run_gpg(vim.list_extend(arguments, recipient_arguments(encrypted_path)), plaintext)

	if encryption.code ~= 0 then
		vim.uv.fs_unlink(staged_path)
		report_gpg_failure("gpg could not encrypt " .. encrypted_path, encryption)
		return
	end

	local renamed, rename_error = vim.uv.fs_rename(staged_path, encrypted_path)
	if not renamed then
		vim.uv.fs_unlink(staged_path)
		vim.notify("Could not replace " .. encrypted_path .. ": " .. rename_error, vim.log.levels.ERROR)
		return
	end

	if event.match == vim.api.nvim_buf_get_name(buffer) then
		vim.bo[buffer].modified = false
	end
	vim.notify(('"%s" encrypted and written'):format(vim.fn.fnamemodify(encrypted_path, ":~:.")))
end

local group = vim.api.nvim_create_augroup("GpgEncryptedFiles", { clear = true })

vim.api.nvim_create_autocmd("BufReadCmd", {
	group = group,
	pattern = encrypted_file_pattern,
	callback = load_decrypted_file,
})

vim.api.nvim_create_autocmd("BufWriteCmd", {
	group = group,
	pattern = encrypted_file_pattern,
	callback = save_encrypted_file,
})
