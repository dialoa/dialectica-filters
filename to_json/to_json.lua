--[[-- # to_json - Pandoc to JSON string conversion 
within Lua filters

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2021 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.1
]]

--- to_json: converts a entire Pandoc document to json
-- @param doc pandoc Pandoc object
function to_json(doc)

	-- build the perl script
	local script = ''
	-- escape backlashes and double quotes
  script = script .. [[ s/\\/\\\\/g; ]] .. [[ s/\"/\\"/g; ]]
	-- wrap the result in an empty element with a RawBlock element
	local before = '{"pandoc-api-version":[1,22],"meta":{},"blocks":'
									.. '[{"t":"RawBlock","c":["json","'
	local after =	'"]}]}'
	script = script .. [[ s/^/ ]] .. before .. [[ /; ]] 
		.. [[ s/$/ ]] .. after  .. [[ / ]]

	-- run the filter, catch the result in the `text` field of the first block
	local result = pandoc.utils.run_json_filter(doc, 'perl', {'-pe', script})

	-- return the string or nil
	return result.blocks[1].c[2] or nil

end

-- Main filter: test the to_json function

return {{

	Pandoc = function(doc)
		print(to_json(doc))
	end,

	-- in the future, we'd like to_json to cover arbitrary pandoc AST objects
	-- at least elements in the body, Meta / Meta elements
	-- Attributes is less necessary
	-- Div = function (elem) 
	-- 	if elem.classes and elem.classes:includes('serialize') then
	-- 		print(to_json(elem))
	-- 	end
	-- end

}}

