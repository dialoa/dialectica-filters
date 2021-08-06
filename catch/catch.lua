--- Catch: a filter to catch the Pandoc AST before it's out
-- useful to run Pandoc with FORMAT=html... and yet
-- catch the result in Json

--  # Helper function: to_json

function to_json(doc)

	-- check that doc is a Pandoc object
	if not (doc.meta and doc.blocks) then
		return nil
	end
	-- prepare command to wrap json stdin in a json representation
	-- of a Pandoc document. Use sed on *nix and powershell on windows
	local command = ''
	local arguments = pandoc.List:new()
	--	strings to build an empty document with a RawBlock element
	local api_ver_str = tostring(PANDOC_API_VERSION):gsub('%.',',')
	local before = '{"pandoc-api-version":[' .. api_ver_str .. '],'
		.. [["meta":{},"blocks":[{"t":"RawBlock","c":["json","]]
	local after =	[["]}]}]]
	local result = nil
	if pandoc.system.os == 'mingw32' then
		-- we need to set input and output in utf8
		-- before run_json_filter is called
		-- [Console]::OutputEncoding for stdin
		-- $OutputEncoding for stdout
		-- see https://stackoverflow.com/questions/49476326/displaying-unicode-in-powershell
		-- @TODO find a way to restore later! we can't use variables
		-- as they are dumped at the end of this call
		os.execute([[PowerShell -NoProfile -Command ]]
			.. ' [Console]::OutputEncoding=[Text.Encoding]::utf8;'
			.. ' $OutputEncoding=[Text.Encoding]::utf8;'
			)
		command = 'powershell'
		arguments:extend({'-NoProfile', '-Command'})
		-- write the powershell script
		-- (for some reason it isn't necessary to wrap it in double quotes)
		local pwsh_script = ''
		-- manipulate stdin
		pwsh_script = pwsh_script .. '$input'
		-- escape backslashes and double quotes
		pwsh_script = pwsh_script .. [[ -replace '\\','\\']]
			.. [[ -replace '\"','\"']]
		-- wrap the result in an empty document with a RawBlock element
		pwsh_script = pwsh_script .. " -replace '^','" .. before .. "'"
				.. " -replace '$','" .. after .. "'"
		arguments:insert(pwsh_script)

		result = pandoc.utils.run_json_filter(doc, command, arguments)
		-- restore console settings here

	else
		command = 'sed'
		local sed_script = ''
		-- escape backlashes and double quotes
		sed_script = sed_script .. [[s/\\/\\\\/g; ]] .. [[s/\"/\\"/g; ]]
		-- wrap the result in an empty document with a RawBlock element
		sed_script = sed_script .. [[s/^/]] .. before .. [[/; ]] 
			.. [[s/$/]] .. after .. [[/; ]]
		arguments:insert(sed_script)

		result = pandoc.utils.run_json_filter(doc, command, arguments)

	end

	-- catch the result in the `text` field of the first block
	-- return nil if faileds
	return result.blocks[1].c[2] or nil

end

-- MAIN FUNCTION
function catch(doc)
	local filename = ''
	if doc.meta and doc.meta['catch-file'] then
		filename = pandoc.utils.stringify(doc.meta['catch-file'])
	else
		filename = 'caught-document.json'
	end

	print(FORMAT)
	local file = io.open(filename, 'w')
	file:write(to_json(doc))
	file:close()
	return pandoc.Pandoc({},{})
end

return{{
	Pandoc = function(doc)
		return catch(doc)
	end
}}

