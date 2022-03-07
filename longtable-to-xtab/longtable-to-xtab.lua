--- # Longtable-to-xtab - switch LaTeX table outputs from longtable to xtab.
--
-- This Lua filter for Pandoc converts Pandoc's default `longtable` output
-- of tables in LaTeX with `xtab` tables.
--
-- @author Julien Dutant <julien.dutant@kcl.ac.uk>
-- @copyright (c) 2021 Julien Dutant
-- @license MIT - see LICENSE file for details.
-- @release 1.0

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

--- Add a block to the document's header-includes meta-data field.
-- @param meta the document's metadata block
-- @param block Pandoc block element (e.g. RawBlock or Para) to be added to header-includes
-- @return meta the modified metadata block
local function add_header_includes(meta, block)

    local header_includes

    -- make meta['header-includes'] a list if needed
    if meta['header-includes'] and type(meta['header-includes']) == 'List' then
        header_includes = meta['header-includes']
    else
        header_includes = pandoc.MetaList{meta['header-includes']}
    end

    -- insert `block` in header-includes and add it to `meta`

    header_includes[#header_includes + 1] =
        pandoc.MetaBlocks{block}

    meta['header-includes'] = header_includes

    return meta
end

--- Main filter

local filter = {

  Meta = function (element)

    local latex_code = [[
  \usepackage{xtab}
  \renewenvironment{longtable}{%
    \begin{center}\begin{xtabular}%
    }{%
    \end{xtabular}\end{center}%
    }
  \renewcommand{\caption}[1]{}
  \renewcommand{\endhead}{}
  ]]

    add_header_includes(element, pandoc.RawBlock('latex', latex_code))

    return element

  end,

 Table = function (element)

    if element.caption and #element.caption['long'] > 0 then

      local result = pandoc.List:new({})
      local inlines = pandoc.List:new({})

      inlines:insert(pandoc.RawInline('latex', '\\tablecaption{'))
      inlines:extend(pandoc.utils.blocks_to_inlines(element.caption['long']))
      inlines:insert(pandoc.RawInline('latex', '}'))

      result:insert(pandoc.Plain(inlines))

      -- place the table
      result:insert(element)

      -- if the table has both header and caption we need to hide the
      -- duplicate header. We turn `\endfirsthead` into `\iffalse`
      -- and `\endhead` into `\fi`. The latter must be present
      -- when `\iffalse` is encountered, so we use `\let` for the
      -- latter and `\renewcommand` for the former.
      -- we wrap the whole in `{...}` to avoid affecting `\endhead`
      -- down the line.
      if #element.head[2] > 0 then

        latex_pre = [[{
  {\renewcommand{\endfirsthead}{\iffalse}
  \let\endhead\fi
        ]]
        latex_post = '}'

        result:insert(1, pandoc.RawBlock('latex', latex_pre))
        result:insert(pandoc.RawBlock('latex', latex_post))

      end

      return result

    end

  end
}

-- return filter if targetting LaTeX
if FORMAT:match('latex') then
  return {filter}
end
