--[[-- # Sections-to-meta - moves `abstract`, `thanks`
and `keywords` section to metadata

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2021 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.1
]]

-- # Options

-- abstract, thanks: list of blocks
-- keywords: list of list of blocks
local abstract = pandoc.List()
local thanks = pandoc.List()
local keywords = pandoc.List()
local reviewof = pandoc.List()
local fields_and_aliases = {
  abstract = pandoc.List:new({'abstract', 'summary'}),
  thanks = pandoc.List:new({'thanks', 
    'acknowledgments', 'acknowledgements'}),
  keywords = pandoc.List:new({'keywords'}),
  reviewof = pandoc.List:new({'reviewof', 'review-of', 'review of'})
}

--- Extract meta from a list of blocks.
function meta_from_blocklist (blocks)
  local body_blocks = pandoc.List()
  -- whether the current block is part of `body`, `abstract` etc 
  local looking_at = 'body' 

  for _, block in ipairs(blocks) do

    -- Are we starting a new metadata section? 
    -- if not, store into body text
    if block.t == 'Header' then
      local header_str = pandoc.utils.stringify(block.content):lower()
      local new_metadata_section = false
      for field,aliases in pairs(fields_and_aliases) do
        if aliases:find(header_str) then
            new_metadata_section = true
            looking_at = field
            break
        end
      end
      -- if we haven't found a metadata header, it's part of the body
      if not new_metadata_section then
        looking_at = "body"
        body_blocks:insert(block)
      end
    -- Horizontal Rule: if we're looking at metadata, stop
    --  otherwise keep the rule in blocks
    -- fake horizontal rule: a paragraph with `* * *`
    elseif block.t == 'HorizontalRule' or 
      (block.t == 'Para' and pandoc.utils.stringify(block) == '* * *')
      then
        if not (looking_at == "body") then
          looking_at = "body"
        else
          body_blocks:insert(block)
        end
    -- if looking at metadata: store it
    elseif looking_at == "abstract" then
      abstract:insert(block)
    elseif looking_at == "thanks" then
      thanks:insert(block)
    elseif looking_at == "reviewof" then
      reviewof:insert(block)
    elseif looking_at == "keywords" then
       if block.t == "BulletList" then
        keywords:insert(block)
       end
    else
      body_blocks:insert(block)
    end
  end

  return body_blocks
end

-- Turn list of BulletList elements into
-- a MetaList of MetaInlines
function bulletlist_to_metalist (keywords)
  local keyword_list = pandoc.List(pandoc.MetaList({}))
  for _,bullet_list in ipairs(keywords) do
    for _,item in ipairs(bullet_list.c) do

      -- we only use the first block of each item,
      -- and we only use it if it is Plain or Para
      if item[1] and (item[1].t == "Plain" or item[1].t == "Para") then
        keyword_list:insert(pandoc.MetaInlines(item[1].c))
      end

    end
  end

  return keyword_list
end

return {{
    Blocks = meta_from_blocklist,
    Meta = function (meta)
      if not meta.abstract and #abstract > 0 then
        meta.abstract = pandoc.MetaBlocks(abstract)
      end
      if not meta.thanks and #thanks > 0 then
        meta.thanks = pandoc.MetaBlocks(thanks)
      end
      if not meta.reviewof and #reviewof > 0 then
        meta.reviewof = pandoc.MetaBlocks(reviewof)
      end
      if not meta.keywords and #keywords > 0 then
        meta.keywords = bulletlist_to_metalist(keywords)
       end
      return meta
    end
}}
