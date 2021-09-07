--[[-- # Prefix-ids - Prefixings all ids in a Pandoc document

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2021 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.1
]]

-- # Global variables
local prefix = '' -- user's custom prefix
local old_identifiers = pandoc.List:new() -- identifiers removed
local ids_to_ignore = pandoc.List:new() -- identifiers to ignore
local pandoc_crossref = true -- do we process pandoc-crossref links?
local crossref_prefixes = pandoc.List:new({'fig','sec','eq','tbl','lst'})
local crossref_str_prefixes = pandoc.List:new({'eq','tbl','lst'}) -- in Str elements
local codeblock_captions = true -- is the codeblock caption syntax on?

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
        if meta['prefix-ids'].ignoreids and 
            meta['prefix-ids'].ignoreids.t == 'MetaList' then
            ids_to_ignore:extend(meta['prefix-ids'].ignoreids)
        end
        
    end

    -- if meta.codeBlockCaptions is false then we should *not*
    -- process `lst:label` identifiers that appear in Str elements
    -- (that is, in codeblock captions). We will still convert
    -- those that appear as CodeBlock attributes
    if not meta.codeBlockCaptions then
        codeblock_captions = false
        crossref_str_prefixes = crossref_str_prefixes:filter(
            function(item) return item ~= 'lst' end)
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
        if el.identifier and el.identifier ~= '' 
            and not ids_to_ignore:find(el.identifier) then
            -- if pandoc-crossref type, we add the prefix after "fig:", "tbl", ...
            -- though (like pandoc-crossref) we must ignore #lst:label unless there's 
            -- a caption attribute or the codeblock caption syntax is on
            if pandoc_crossref then
                local type, identifier = el.identifier:match('^(%a+):(.*)')
                if type and identifier and crossref_prefixes:find(type) then
                    -- special case in which we don't touch it:
                    -- a codeblock with #lst:label id but no caption
                    -- nor caption table syntax on
                    if el.t == 'CodeBlock' and not codeblock_captions 
                        and type == 'lst' and (not el.attributes
                            or not el.attributes.caption) then
                        return
                    -- in all other cases we add prefix between `type`
                    -- and `identifier`
                    -- NOTE: in principle we should check that if it's
                    -- a codeblock it has a caption paragraph before or
                    -- after, but that requires going through the doc
                    -- el by el, not worth it. 
                    else
                        old_identifiers:insert(type .. ':' .. identifier)
                        el.identifier =  type .. ':' .. prefix .. identifier
                        return el
                    end
                end
            end
            -- if no pandoc_crossref action was taken, apply simple prefix
            old_identifiers:insert(el.identifier)
            el.identifier = prefix .. el.identifier
            return el
        end
    end
    -- add_prefix_string function
    -- same as add_prefix but for pandoc-crossref "{eq:label}" strings
    -- crossref_srt_prefixes tell us which ones to convert
    add_prefix_string = function(el)
        local type, identifier = el.text:match('^{#(%a+):(.*)}')
        if type and identifier 
          and crossref_str_prefixes:find(type)
          and not ids_to_ignore:find(type .. ':' .. identifier) then
            old_identifiers:insert(type .. ':' .. identifier)
            local new_id = type .. ':' .. prefix .. identifier
            return pandoc.Str('{#' .. new_id .. '}')
        end
    end

    -- apply the functions to all elements with identifier
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
                local type, identifier = target:match('^(%a+):(.*)')
                if type and crossref_prefixes:find(type) then
                    target = '#' .. type .. ':' .. prefix .. identifier
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
            local type, target = cite.citations[i].id:match('^(%a+):(.*)')
            if type and crossref_prefixes:find(type) then
                if old_identifiers:find(type .. ':' .. target) then
                    cite.citations[i].id = type .. ':' .. prefix .. target
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
