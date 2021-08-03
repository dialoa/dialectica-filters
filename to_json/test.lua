function Pandoc(doc)
	-- return pandoc.utils.run_json_filter(doc, 'powershell',{
	-- 	'-NoProfile',
	-- 	'-Command',
	-- 	[["$input"]]
	-- })
	-- return pandoc.utils.run_json_filter(doc, 'powershell',{
	-- 	'-NoProfile',
	-- 	'-Command',
	-- 	[[$input -replace '\$','g']]
	-- })
		local command = 'powershell'
		local arguments = pandoc.List:new({'-NoProfile', '-Command'})
		-- write the powershell script
		-- (for some reason it isn't necessary to wrap it in double quotes)
		local pwsh_script = ''
		-- set input and output in utf8
		pwsh_script = pwsh_script .. '[console]::inputencoding=[text.encoding]::utf8;'
			.. ' $outputencoding=[console]::outputencoding=[text.encoding]::utf8;'
			.. ' Out-Default;' -- activates these settings before next command
		-- manipulate stdin
		pwsh_script = pwsh_script .. '$input'
		-- escape backslashes and double quotes
		pwsh_script = pwsh_script .. [[ -replace '\\','\\']]
			.. [[ -replace '\"','\"']]
		-- wrap the result in an empty document with a RawBlock element
		local before = [[{"pandoc-api-version":[1,22],"meta":{},"blocks":]]
						.. [[[{"t":"RawBlock","c":["json","]]
		local after =	[["]}]}]]
		pwsh_script = pwsh_script .. " -replace '^','" .. before .. "'"
				.. " -replace '$','" .. after .. "'"
		-- powershell command must be in double quotes
		-- pwsh_script = '"' .. pwsh_script .. '"'
		arguments:insert(pwsh_script)

	local tester = 'Sømé Üñicode ぁ あ ぃ い te\\ssdsdwr" tas\\f wersa" ddgs'
	print('Original: ' .. tester)
	print('After pipe: ' .. pandoc.pipe(command, arguments, tester))
end