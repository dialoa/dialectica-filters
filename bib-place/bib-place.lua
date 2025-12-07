--- # bib-place: template-controlled bibliography
--    placement in Pandoc.
--
-- This Lua filter for Pandoc allows placement of the bibliography
-- to be controlled in pandoc templates.
--
-- @author Julien Dutant <julien.dutant@kcl.ac.uk>
-- @author Albert Krewinkel
-- @copyright 2021 Julien Dutant, Albert Krewinkel
-- @license MIT - see LICENSE file for details.
-- @release 0.1

local references = pandoc.List({})

--- Filter for the document's blocks
--Scan body from last block backwards, look for the `refs` Div,
--If present, check the element right before and pick
--it up if it's a header or a `refs-preamble` Div.
--The `refs-preamble` Div is dissolved.
-- @param element a Div element
-- @return an empty list if Div has identifier `refs`
local blocks_filter = {

  Pandoc = function (doc)

    local previous_was_refs = false

    for i = #doc.blocks, 1, -1 do

      if previous_was_refs then
        if doc.blocks[i].t == 'Header' then
          references:insert(1, pandoc.MetaBlocks( { doc.blocks[i] } ))
          doc.blocks:remove(i)
          break
        elseif doc.blocks[i].t == 'Div' and 
          doc.blocks[i].identifier == 'refs-preamble' then
            references:extend(pandoc.MetaBlocks( doc.blocks[i].content ))
            doc.blocks:remove(i)
        else
          break
        end

      elseif doc.blocks[i].identifier == 'refs'
          or ( doc.blocks[i].classes and
            doc.blocks[i].classes:includes('csl-bib-body') ) then

        references:insert(pandoc.MetaBlocks( { doc.blocks[i] } ))
        doc.blocks:remove(i) -- remove the Div
        previous_was_refs = true

      end

    end

    return(doc)

  end
}

--- Metadata filter.
-- Places the references block (as string) in the `references`
-- field of the document's metadata. The template can
-- print it by using `$meta.references$`.
-- @param meta the document's metadata block
-- @return the modified metadata block
local metadata_filter = {
  Meta = function (meta)
    meta.referencesblock = references
    return meta
  end
}

--- Main code
-- Returns the filters in the desired order of execution
return {
  blocks_filter,
  metadata_filter
}
