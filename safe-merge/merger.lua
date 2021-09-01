-- Copyright 2021 Thomas Hodgson
-- MIT License, see ../LICENSE for details

local a = pandoc.read(io.open('a.md', 'r'):read('a'))
local b = pandoc.read(io.open('b.md', 'r'):read('a'))

function safely_merge(olddoc, newdoc)
    -- store the IDs in olddoc
    local olddoc_ids = {}
    -- keep a table of what links have been updated
    local old_to_new = {}
    -- function to add an element's ID to the stored IDs
    function get_id(el)
        if el.identifier and el.identifier ~= '' then
            olddoc_ids[el.identifier] = true
        end
    end
    -- replace an ID with one with a suffix, which is the first integer which gives
    -- a new ID
    function update_id(el)
        if el.identifier and el.identifier ~= '' and olddoc_ids[el.identifier] then
            suffix = 1
            while olddoc_ids[el.identifier .. '-' .. suffix] do
                suffix = suffix + 1
            end
            new_id = el.identifier .. '-' .. suffix
            old_to_new[el.identifier] = new_id
            el.identifier = new_id
            return el
        end
    end
    -- replace link targets according to the table of updated links
    function update_link(el)
        if old_to_new[el.target:sub(2, -1)] then
            el.target = '#' .. old_to_new[el.target:sub(2, -1)]
            return el
        end
    end
    -- make the list of IDs
    pandoc.walk_block(
        pandoc.Div(olddoc.blocks),
        {
            Block = get_id,
            Inline = get_id,
        }
    )
    -- make a new doc with updated IDs
    local updated_ids = pandoc.Pandoc(
        pandoc.walk_block(
            pandoc.Div(newdoc.blocks),
            {
                Block = update_id,
                Inline = update_id,
            }
        )
    )
    -- make a new doc with updated links
    local updated_links = pandoc.Pandoc(
        pandoc.walk_block(
            pandoc.Div(updated_ids.blocks),
            {
                Link = update_link,
            }
        )
    )
    -- return a Pandoc document with the blocks of the old doc,
    -- and the blocks of the updated doc
    return pandoc.Pandoc(olddoc.blocks .. updated_links.blocks)
end

function Pandoc(doc)
    return safely_merge(a, b)
end
