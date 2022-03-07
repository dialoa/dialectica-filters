--[[-- # to_json - Pandoc to JSON string conversion 
within Lua filters

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2021 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.2
]]

--- to_json: converts a entire Pandoc document to json
-- @param doc pandoc Pandoc object to be converted to json
-- @return string json string representation if success, nil if failed
-- @TODO in Win, use Python or Perl if present, powershell is slow
function to_json(doc)

	-- in Pandoc >= 2.17, we can simply use pandoc.write
	if PANDOC_VERSION >= '2.17' then
		if pandoc.utils.type(doc) == 'Pandoc' then
			return pandoc.write(doc, 'json')
		else
			return nil
		end
	end

	-- in Pandoc <= 2.17, first confirm that doc is Pandoc object
	if not (doc.meta and doc.blocks) then
		return nil
	end

	-- pandoc.utils.run_json_filter(doc, command) converts the Pandoc
	-- doc to its JSON representation, sends it to stdin, executes
	-- `command` expects a JSON representation of a Pandoc document 
	-- return. Our `command` simply wraps the json string Pandoc 
	-- stands to stdin in (a JSON representation) of a Pandoc document
	-- with a Rawblock containing that string. 
	-- we use `sed` on MacOs/Linux systems and Powershell on Win.
	local command = ''
	local arguments = pandoc.List:new()
	-- strings to build an json representation of an empty document 
	-- with a RawBlock element
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
	-- return nil if failed
	return result.blocks[1].text or nil

end

-- Main filter: test the to_json function

return {{

	Pandoc = function(doc)
		print(to_json(doc))
		return pandoc.Pandoc({},{})
	end
}}

