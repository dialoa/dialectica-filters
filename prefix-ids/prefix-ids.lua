--[[-- # Prefix-ids - Prefixings all ids in a Pandoc document

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2021 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.1
]]

-- # Global variables
local prefix = ''
local old_identifiers = pandoc.List:new()
local pandoc_crossref = true
local crossref_prefixes = pandoc.List:new({'fig','sec','eq','tbl','lst'})

--- get_options: get filter options for document's metadata
-- @param meta pandoc Meta element
function get_options(meta)

    -- syntactic sugar: options aliases
    -- merging behaviour: aliases prevail
    local aliases = {'prefix', 'pandoc-crossref'}
    for _,alias in ipairs(aliases) do
        if meta['prefix-ids-' .. alias] ~= nil then
            -- create a 'prefix-ids' key if needed
            if not meta['prefix-ids'] then
                meta['prefix-ids'] = pandoc.MetaMap({})
            end
            meta['prefix-ids'][alias] = meta['prefix-ids-' .. alias]
            meta['prefix-ids-' .. alias] = nil
        end
    end

    -- save options in global variables
    if meta['prefix-ids'] then

        if meta['prefix-ids']['prefix'] then
            prefix = pandoc.utils.stringify(meta['prefix-ids']['prefix'])
        end
        if meta['prefix-ids']['pandoc-crossref'] ~= nil 
          and meta['prefix-ids']['pandoc-crossref'] == false then
            pandoc_crossref = false
        end
        
    end
    return meta
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
            local new_identifier = ''
            -- if pandoc-crossref type, we add the prefix after "fig:"
            if pandoc_crossref then 
                local type = el.identifier:match('^(%a+):')
                if crossref_prefixes:find(type) then
                    new_identifier = type .. ':' .. prefix 
                        .. el.identifier:match('^%a+:(.*)')
                else
                    new_identifier = prefix .. el.identifier
                end
            else
                new_identifier = prefix .. el.identifier
            end
            el.identifier = new_identifier
            return el
        end
    end
    -- add_prefix_string function
    -- same as add_prefix but for pandoc-crossref "{eq:label}" strings
    add_prefix_string = function(el)
        local eq_identifier = el.text:match('{#eq:(.*)}')
        if eq_identifier then
            old_identifiers:insert('eq:' .. eq_identifier)
            return pandoc.Str('{#eq:' .. prefix .. eq_identifier .. '}')
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
        Str = pandoc_crossref and add_prefix_string
    })
    doc.blocks = div.content

    -- function to add prefixes to links
    local add_prefix_to_link = function (link)
        if link.target:sub(1,1) == '#' 
          and old_identifiers:find(link.target:sub(2,-1)) then
            local target = link.target:sub(2,-1)
            -- handle pandoc-crossref types targets if needed
            if pandoc_crossref then
                local type = target:match('^(%a+):')
                if crossref_prefixes:find(type) then
                    target = '#' .. type .. ':' .. prefix 
                        .. target:match('^%a+:(.*)')
                else
                    target = '#' .. prefix .. target
                end
            else
                target = '#' .. prefix .. target
            end
            link.target = target
            return link 
        end
    end
    -- function to add prefixes to pandoc-crossref citations
    -- looking for keys starting with `fig:`, `sec:`, `eq:`, ... 
    local add_prefix_to_crossref_cites = function (cite)
        for i = 1, #cite.citations do
            local type = cite.citations[i].id:match('^(%a+):')
            if crossref_prefixes:find(type) then
                local target = cite.citations[i].id:match('^%a+:(.*)')
                if old_identifiers:find(type .. ':' .. target) then
                    target = prefix .. target
                    cite.citations[i].id = type .. ':' .. target
                end
            end
        end
        return cite
    end

    div = pandoc.walk_block(pandoc.Div(doc.blocks), {
        Link = add_prefix_to_link,
        Cite = pandoc_crossref and add_prefix_to_crossref_cites
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
