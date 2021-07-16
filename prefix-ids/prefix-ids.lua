--[[-- # Prefix-ids - Prefixings all ids in a Pandoc document

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2021 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.1
]]

-- # Global variables
local prefix = ''
local old_identifiers = pandoc.List:new()

--- get_options: get filter options for document's metadata
-- @param meta pandoc Meta element
function get_options(meta)
    if meta['prefix_ids'] then

        if meta['prefix-ids']['prefix'] then
            prefix = pandoc.utils.stringify(meta['prefix-ids']['prefix'])
        end
        
    end
end

--- process_doc: process the pandoc document
-- generates a prefix is needed, walk through the document
-- and adds a prefix to all elements with identifier.
-- @param pandoc Pandoc element
-- @TODO handle meta fields that may contain identifiers? abstract
-- and thanks?
function process_doc(doc)

    -- generate prefix if needed
    if prefix == '' then
        prefix = pandoc.utils.sha1(pandoc.utils.stringify(doc.blocks))
    end

    -- add_prefix function
    -- do not add prefixes to empty identifiers
    -- store the old identifiers for fixing the links
    add_prefix = function (el) 
        if el.identifier and el.identifier ~= '' then
            old_identifiers:insert(el.identifier)
            local new_identifier = prefix .. el.identifier
            el.identifier = new_identifier
            return el
        end
    end

    -- apply the function to all elements with identifier
    local div = pandoc.walk_block(pandoc.Div(doc.blocks), {
        Span = add_prefix,
        Link = add_prefix,
        Image = add_prefix,
        Code = add_prefix,
        Div = add_prefix,
        Header = add_prefix,
        Table = add_prefix,
        CodeBlock = add_prefix,        
    })
    doc.blocks = div.content

    local add_prefix_to_link = function (link)
        if link.target:sub(1,1) == '#' 
          and old_identifiers:find(link.target:sub(2,-1)) then
            new_target = '#' .. prefix .. link.target:sub(2,-1)
            link.target = new_target
            return link 
        end
    end

    div = pandoc.walk_block(pandoc.Div(doc.blocks), {
        Link = add_prefix_to_link
    })
    doc.blocks = div.content

    -- return the result
    return doc

end

-- # Main filter
return {
    {
        Meta = get_options,
        Pandoc = process_doc
    }
}
