--[[-- # Labelled-lists - custom labelled lists
 in Pandoc's markdown.

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2021 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.1
]]

-- # Internal settings

-- target_formats  filter is triggered when those format are targeted
local target_formats = {
  "html.*",
  "latex",
  "jats",
}

-- table of indentified labels
local label_ids = pandoc.List:new()

-- # Helper functions

--- format_matches: Test whether the target format is in a given list.
-- @param formats list of formats to be matched
-- @return true if match, false otherwise
function format_matches(formats)
  for _,format in pairs(formats) do
    if FORMAT:match(format) then
      return true
    end
  end
  return false
end

--- message: send message to std_error
-- @param type string INFO, WARNING, ERROR
-- @param text string text of the message
function message(type, text)
    local level = {INFO = 0, WARNING = 1, ERROR = 2}
    if level[type] == nil then type = 'ERROR' end
    if level[PANDOC_STATE.verbosity] <= level[type] then
        io.stderr:write('[' .. type .. '] Labelled-lists lua filter: ' 
            .. text .. '\n')
    end
end

-- # Filter functions

--- build_list: processes a custom label list
-- 
-- you need to return an item that's not a list, but
-- contains output format code for lists
function build_list(element)

    -- build a list of blocks
    local list = pandoc.List:new()

    -- start

    if FORMAT:match('latex') then
        list:insert(pandoc.RawBlock('latex',
            '\\begin{itemize}\n\\tightlist'
            ))
    end

    -- process each item

    for _,blocks in ipairs(element.c) do

        -- get the span, remove it, extract content
        local span = blocks[1].c[1]
        blocks[1].c:remove(1)
        local label = span.content
        local id = ''

        -- get identifier if not duplicate, store in global table
        if not (span.identifier == '') then
            if label_ids[span.identifier] then
                message('WARNING', 'duplicate item identifier ' 
                    .. span.identifier .. '. The second is ignored.')
            else
                label_ids[span.identifier] = label
                id = span.identifier
            end
        end

        if FORMAT:match('latex') then

            inlines = pandoc.List:new()
            inlines:insert(pandoc.RawInline('latex','\\item['))
            inlines:extend(label)
            inlines:insert(pandoc.RawInline('latex',']'))
            list:insert(pandoc.Plain(inlines))

            list:extend(blocks)

        elseif FORMAT:match('html') then

            -- TO BE CONTINUED

        end

    end

    for k,v in pairs(label_ids) do
        print("id " .. k .. " label " .. pandoc.utils.stringify(v) )
    end


    -- end

    if FORMAT:match('latex') then
        list:insert(pandoc.RawBlock('latex',
            '\\end{itemize}\n'
            ))
    end

    return list
end

--- is_custom_labelled_list: Look for custom labels markup
-- Custom label markup requires each item starting with a span
-- containing the label
-- @param element pandoc BulletList element
function is_custom_labelled_list (element)

    local is_cl_list = true

    -- the content of BulletList is a List of List of Blocks
    for _,blocks in ipairs(element.c) do

        -- check that the first element of the first block is Span
        -- and not empty
        if not( blocks[1].c[1].t == 'Span' ) or 
            pandoc.utils.stringify(blocks[1].c[1].content) == '' then
            is_cl_list = false
            break 
        end
    end

    return is_cl_list
end

--- filter_list: Process custom labelled lists
-- If a list has the custom label markup, process labels
-- @param element pandoc BulletList element
function filter_list (element)
    
    if is_custom_labelled_list(element) then
        print("found a cl list")
        return build_list(element)
    end

end

--- Main code
-- return the filter on BulletList elements
if format_matches(target_formats) then
    return {
      {
        BulletList = filter_list
      },
    }
end