--[[-- # Statement-isolate

Hack to fix the conflicting LaTeX code created
by the statement filter when chapters are imported 
as raw code. 

Avoids duplicates `newtheorem` environment.

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2022 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.1
]]

-- # Options

-- keep track of existing environments
local thm_envs = pandoc.List:new()
-- dynamic replacement table
local replace = pandoc.List:new()

function isolate(block) 
	if not block.format:match('latex') then
		return nil
	end

	-- substitute environment names where needed
	local patterns = {
		newthm = '\\(newtheorem%*?)(%b{})', 
		begenv = '\\(begin)(%b{})',
	    endenv = '\\(end)(%b{})',
	}
	local source = block.text
	local result = ''
	local command = ''

	while #source > 0 do
		-- look for the first matching command
		local firstpos, lastpos
		for _,pattern in pairs(patterns) do
			local i, j = source:find(pattern)
			if i and (not firstpos or i < firstpos) then
				firstpos, lastpos = i , j
			end
		end

		-- break if nothing found
		if not firstpos then
			result = result .. source
			source = ''
			break
		end

		-- split the source
		result = result .. source:sub(1,firstpos - 1)
		command = source:sub(firstpos,lastpos)
		source = source:sub(lastpos+1, -1)

		-- substitutions
		local cmd_str, thm_name

		-- newtheorem substitution
		cmd_str, thm_name = command:match(patterns.newthm)
		if cmd_str then
			-- strip the {, }
			thm_name = thm_name:sub(2,-2)

			-- duplicate of an existing theorem?
			if thm_envs:find(thm_name) then
				-- create a new name
				local new_name = replace[thm_name] or thm_name
				while thm_envs:find(new_name) do
					new_name = new_name .. '_'
				end
				-- store it
				thm_envs:insert(new_name)
				-- insert (new) replacement rule for thm_name
				replace[thm_name] = new_name
			else
				thm_envs:insert(thm_name)
			end

			-- replacement needed?
			command = '\\' .. cmd_str .. '{' ..(replace[thm_name] or thm_name).. '}'

		else

			-- begin / end substitution

			cmd_str, thm_name = command:match(patterns.begenv)
			if not cmd_str then
				cmd_str, thm_name = command:match(patterns.endenv)
			end

			if cmd_str then
				-- strip the {, }
				thm_name = thm_name:sub(2,-2)
				-- replacement needed?
				command = '\\' .. cmd_str .. '{' ..(replace[thm_name] or thm_name).. '}'
			end

		end

		result = result..command

	end

	block.text = result

	return block

end

-- main filter
if FORMAT:match('latex') then
	return {{
		RawBlock = isolate,
	}}
else 
	return nil
end