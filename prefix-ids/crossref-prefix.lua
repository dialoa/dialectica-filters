--[[-- # Crossref-prefix - Prefixings pandoc-crossref ids 
and links in a Pandoc document

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2021 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.1
]]

-- # Global variables
local prefix = '' -- user's custom prefix
local old_identifiers = pandoc.List:new() -- identifiers removed
local new_identifiers = pandoc.List:new() -- identifiers added
local pandoc_crossref = true -- do we process pandoc-crossref links?
local crossref_prefixes = pandoc.List:new({'fig','sec','eq','tbl','lst',
        'Fig','Sec','Eq','Tbl','Lst'})
local crossref_str_prefixes = pandoc.List:new({'eq','tbl','lst',
        'Eq','Tbl','Lst'}) -- found in Str elements (captions or after eq)
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
    -- check that it's a pandoc-crossref type
    -- do not add prefixes to empty identifiers
    -- store the old identifiers to later fix links
    add_prefix = function (el)
        if el.identifier and el.identifier ~= '' then
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
                        new_id =  type .. ':' .. prefix .. identifier
                        el.identifier = new_id
                        new_identifiers:insert(new_id)
                        return el
                    end
                end
            end
            -- if no pandoc_crossref action was taken, apply simple prefix
            old_identifiers:insert(el.identifier)
            new_id = prefix .. el.identifier
            el.identifier = new_id
            new_identifiers:insert(new_id)
            return el
        end
    end
   -- add_prefix_string function
    -- handles {#eq:label} for equations and {#tbl:label} or {#lst:label}
    -- in table or listing captions. 
    add_prefix_string = function(el)
        local type, identifier = el.text:match('^{#(%a+):(.*)}')
        if type and identifier and crossref_str_prefixes:find(type) then
            old_identifiers:insert(type .. ':' .. identifier)
            local new_id = type .. ':' .. prefix .. identifier
            new_identifiers:insert(new_id)
            return pandoc.Str('{#' .. new_id .. '}')
        end
    end


    -- apply the function to all elements with pandoc-crossref identifiers
    local div = pandoc.walk_block(pandoc.Div(doc.blocks), {
        Image = add_prefix,
        Header = add_prefix,
        Table = add_prefix,
        CodeBlock = add_prefix,
        Str = add_prefix_string,
    })
    doc.blocks = div.content

   -- function to add prefixes to links
    local add_prefix_to_link = function (link)
        if link.target:sub(1,1) == '#' 
          and old_identifiers:find(link.target:sub(2,-1)) then
            local target = link.target:sub(2,-1)
            local type = target:match('^(%a+):')
            if crossref_prefixes:find(type) then
                link.target = '#' .. type .. ':' .. prefix 
                    .. target:match('^%a+:(.*)')
                return link
            end
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

    div = pandoc.walk_block(pandoc.Div(doc.blocks), {
        Link = add_prefix_to_link,
        Cite = add_prefix_to_crossref_cites
    })
    doc.blocks = div.content

    -- set metadata (in case prefix-ids is ran later on)
    -- save a list of ids changed
    if not doc.meta['prefix-ids'] then
        doc.meta['prefix-ids'] = pandoc.MetaMap({})
    end
    doc.meta['prefix-ids'].ignoreids = pandoc.MetaList(new_identifiers)

    -- return the result
    return doc

end

-- # Main filter
return {
    {
        Meta = get_options,
        Pandoc = function(doc) 
            if pandoc_crossref then return process_doc(doc) end
        end,
    }
}
