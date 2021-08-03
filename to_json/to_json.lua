--[[-- # to_json - Pandoc to JSON string conversion 
within Lua filters

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2021 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.1
]]

--- to_json: converts a entire Pandoc document to json
-- run_json_filter passes a Pandoc object as json to stdin
-- we use regex to put it in the RawBlock of a wrapping json
-- representation of a Pandoc object, so that we can
-- get back the json string
-- @param doc pandoc Pandoc object
-- @string if success, nil if failed
-- @TODO in Win, use Python or Perl if present, powershell is slow
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
	local before = [[{"pandoc-api-version":[1,22],"meta":{},"blocks":]]
						.. [[[{"t":"RawBlock","c":["json","]]
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

-- Main filter: test the to_json function

return {{

	Pandoc = function(doc)
		print(to_json(doc))
		return pandoc.Pandoc({},{})
	end
}}

