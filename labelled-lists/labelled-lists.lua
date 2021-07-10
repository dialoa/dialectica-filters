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

    local level = {
        INFO = 0,
        WARNING = 1,
        ERROR = 2
    }

    if levels[type] == nil then type = 'ERROR' end

    if levels[PANDOC_STATE.verbosity] <= levels[level]

    if PANDOC_STATE.verbosity == 
end

-- # Filter functions

--- build_list: processes a custom label list
-- 
-- you need to return an item that's not a list, but
-- contains output format code for lists
function build_list(element)

    local list = pandoc.List:new()

    -- start

    if FORMAT:match('latex') then
        list:insert(pandoc.RawBlock('latex',
            '\\begin{itemize}\n\\tightlist'
            ))
    end

    -- process each item

    for _,blocks in ipairs(element.c) do

        local span = blocks[1].c[1]
        local label = span
        local id = ''

        if not (span.identifier == '') then
            if label_ids[span.identifier] then
                message('WARNING', 'duplicate item identifier ' 
                    .. span.identifier)
            else
                label_ids[span.identifier] = label
            end

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
        if not( blocks[1].c[1].t == 'Span' ) then
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