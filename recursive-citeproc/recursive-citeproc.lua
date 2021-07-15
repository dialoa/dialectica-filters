--[[-- # Recursive-citeproc - Self-citing Pandoc citeproc
 bibliographies

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2021 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.1
]]

-- # Internal settings

-- NB how to load and use from other filters:
package.path = '../tools/pprint.lua'
local pprint = require('pprint.lua')

--- Options map, including defaults.
local options = {
    max_depth = 5,
}

-- # Global variables
depth = 0

-- # Filter functions

--- get_options: get filter options for document's metadata
-- @param meta pandoc Meta element
function get_options(meta)
    -- no option to provide atm
end

--- parse_nocite(nocite)
-- get a list of citations in a metadata nocite field
-- returns a pandoc List of citation ids (strings)
function parse_nocite(nocite)
    local result = pandoc.List:new()
    local inlines = pandoc.List:new()
    if nocite.t == 'MetaInlines' then
        inlines = nocite
    elseif nocite.t == 'MetaBlocks' then
        inlines = pandoc.utils.blocks_to_inlines(nocite)
    elseif nocite.t == 'MetaList' then
        for _,item in ipairs(nocite) do
            if item.t == 'MetaInlines' then
                inlines:extend(item)
            elseif item.t == 'MetaBlocks' then
                inlines:extend(pandoc.utils.blocks_to_inlines(item))
            end
        end
    end

    pandoc.walk_block(pandoc.Plain(inlines), {
        Cite = function (cite) 
            for _,citation in ipairs(cite.citations) do
                if not result:find(citation.id) then
                    result:insert(citation.id)
                end
            end
        end
    })

    return #result > 0 and result or nil
end

--- create_nocite_field: create a metadata nocite field from 
-- a list of citation ids.
-- returns a pandoc MetaList object
-- @param list list of citation ids (strings)
function create_nocite_field(list)
    local result = pandoc.List:new()
    for _,citationid in ipairs(list) do
        result:insert(pandoc.MetaInlines(
            pandoc.Cite(
                pandoc.Str('@' .. citationid),
                {pandoc.Citation(citationid, 'AuthorInText')}
                )
            )
        )
    end
    return pandoc.MetaList(result)
end

--- collect_citation_ids(doc)
-- Collect all citations ids in a document
-- returns two pandoc Lists of strings with all 
--  citations and nocite citations
-- @param doc pandoc Pandoc document
function collect_citations_ids(doc)
    local all_list = pandoc.List:new()
    local nocite_list = nil
    if doc.meta.nocite then
        nocite_list = parse_nocite(doc.meta.nocite)
        if nocite_list then
            all_list:extend(nocite_list)
        end
    end

    pandoc.walk_block(pandoc.Div(doc.blocks), {
        Cite = function (cite) 
            for _,citation in ipairs(cite.citations) do
                if not all_list:find(citation.id) then
                    all_list:insert(citation.id)
                end
            end
        end
    })
    return all_list, nocite_list
end

--- recursive_citeproc: recursive citeproc processing
-- Run citeproc on the document, checks whether it adds 
-- new citations; if so we put them in `nocite` and 
-- run again until none is added. 
-- @param document pandoc Pandoc element
function recursive_citeproc(document)

    local all_cites, nocite_cites = collect_citations_ids(document)
    -- citations_added = true -- to ensure a first pass

    -- while citations_added do

    local new_doc = pandoc.utils.run_json_filter(document,
        'pandoc',
        {'--from=json', '--to=json', '--citeproc'})
    -- copy the current meta in case previous filters have changed it
    new_doc.meta = document.meta:clone()

    -- check whether citations have been added (or nocite contains @*)
    local new_all_cites, nocite_cites = collect_citations_ids(new_doc)
    if nocite_cites:find('*') or #new_all_cites == #all_cites then
        new_doc.meta['suppress-bibliography'] = true
        return new_doc
    else
    -- otherwise add missing citations to meta, process again

        depth = depth + 1
        if depth < options.max_depth then

            -- insert missing citations ids in nocite_cites
            for _,citation in ipairs(new_all_cites) do
                if not all_cites:find(citation) then
                    nocite_cites:insert(citation)
                end
            end

            -- create metadata nocite field
            document.meta.nocite = create_nocite_field(nocite_cites)

            -- process again
            -- return new_doc
            return recursive_citeproc(document)
            
        end

    end

end


-- # Main filters

return {
    {
        Meta = get_options
    },
    {
        Pandoc = recursive_citeproc
    }
}