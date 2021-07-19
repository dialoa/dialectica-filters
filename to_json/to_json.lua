-- This will not work because the stdin string will contain
-- characters that need to be escaped before being placed
-- in the (native JSON representation of) the RawBlock's content

function to_json(el)
	local before = '{"pandoc-api-version":[1,22],"meta":{},"blocks":'
		.. '[{"t":"RawBlock","c":["json","'
	local after =	'"]}]}'
	local argument = "'s/^/" .. before .. "/;" 
		.. 's/$/' .. after .. "/'"
	-- perl -pe 's/^/START/;s/$/END/'
	return pandoc.utils.run_json_filter(el, 'perl', {'-pe', argument})
end

return {{
	Pandoc = serialize
}}

