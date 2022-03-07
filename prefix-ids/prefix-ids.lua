--[[-- # Prefix-ids - Prefixings all ids in a Pandoc document

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2021 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.2
]]

-- # Global variables
local prefix = '' -- user's custom prefix
local old_identifiers = pandoc.List:new() -- identifiers removed
local ids_to_ignore = pandoc.List:new() -- identifiers to ignore
local pandoc_crossref = true -- do we process pandoc-crossref links?
local crossref_prefixes = pandoc.List:new({'fig','sec','eq','tbl','lst'})
local crossref_str_prefixes = pandoc.List:new({'eq','tbl','lst'}) -- in Str elements
local codeblock_captions = true -- is the codeblock caption syntax on?

--- type: pandoc-friendly type function
-- pandoc.utils.type is only defined in Pandoc >= 2.17
-- if it isn't, we extend Lua's type function to give the same values
-- as pandoc.utils.type on Meta objects: Inlines, Inline, Blocks, Block,
-- string and booleans
-- Caution: not to be used on non-Meta Pandoc elements, the 
-- results will differ (only 'Block', 'Blocks', 'Inline', 'Inlines' in
-- >=2.17, the .t string in <2.17).
local type = pandoc.utils.type or function (obj)
        local tag = type(obj) == 'table' and obj.t and obj.t:gsub('^Meta', '')
        return tag and tag ~= 'Map' and tag or type(obj)
    end


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
            type(meta['prefix-ids'].ignoreids) == 'List' then
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
    -- process_identifiers function
    -- apply the add_prefix and add_prefix_strings functions to blocks
    process_identifiers = function(blocks)
        local div = pandoc.walk_block(pandoc.Div(blocks), {
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
        return div.content
    end

    -- prefix identifiers in doc and in metadata fields with blocks content
    for key,val in pairs(doc.meta) do
        if type(val) == 'Blocks' then
          doc.meta[key] = pandoc.MetaBlocks(
                        process_identifiers(pandoc.List(val))
                    )
        elseif type(val) == 'List' then
            for i = 1, #val do
                if type(val[i]) == 'Blocks' then
                    doc.meta[key][i] = pandoc.MetaBlocks(
                        process_identifiers(pandoc.List(val[i]))
                    )
                end
            end
        end
    end
    doc.blocks = process_identifiers(doc.blocks)

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
            local type, identifier = cite.citations[i].id:match('^(%a+):(.*)')
            if type and identifier and crossref_prefixes:find(type) then
                -- put the type in lowercase to match Fig: and fig:
                -- note that sec: cites might refer to an old identifier
                -- that doesn't start with sec:
                local stype = pandoc.text.lower(type)
                if old_identifiers:find(stype..':'..identifier) or
                  (stype == 'sec' and old_identifiers:find(identifier))
                  then
                    cite.citations[i].id = type..':'..prefix..identifier
                end
            end
        end
        return cite
    end
    -- function to process links and cites in some blocks
    process_links = function(blocks) 
        local div = pandoc.walk_block(pandoc.Div(blocks), {
            Link = add_prefix_to_link,
            Cite = pandoc_crossref and add_prefix_to_crossref_cites
        })
        return div.content
    end

    -- process links and cites in doc and in metablocks fields
    for key,val in pairs(doc.meta) do
        if type(val) == 'Blocks' then
          doc.meta[key] = pandoc.MetaBlocks(
                        process_links(pandoc.List(val))
                    )
        elseif type(val) == 'List' then
            for i = 1, #val do
                if type(val[i]) == 'Blocks' then
                    doc.meta[key][i] = pandoc.MetaBlocks(
                        process_links(pandoc.List(val[i]))
                    )
                end
            end
        end
    end
    doc.blocks = process_links(doc.blocks)

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
