--[[-- # Pre-render - Pandoc Lua filter for pre-rendering
  selected math elements as svg images.

Pre-renders specified maths elements as images. When the target
format isn't LaTeX, any math contained in with a Div or Span
with class "pre-render" will be pre-rendered as svg images.

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2021 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.1
@see inspired by John MacFarlane's filter "Building images with TiKZ"
  in pandoc's documentation <https://pandoc.org/lua-filters.html#examples>
@see Oltolm's `pandoc-latex-math` filter 
  <https://github.com/oltolm/pandoc-latex-math/>
]]

-- # Options
-- in pandoc's documentation <https://pandoc.org/lua-filters.html#examples>
-- @TODO add metadata option to specify raw LaTeX file
-- @TODO convert the caption in proper pandoc code (split by spaces)
-- @TODO get errors from lualatex and dvisvgm, but silent otherwise
-- @TODO use pdf and ghostscript if available (seems safer for fonts)
-- @TODO test with xelatex fonts
-- @TODO Use png for formats that don't handle SVG (docx, pptx, rtf)
-- @TODO improve code following diagram-generator style
-- @TODO for Math return Spans with `math display` or `math inline` classes,
--    like Pandoc
-- @TODO fix font sizes (1.21 times bigger, says Katex?)

-- # Global variables

local system = pandoc.system
local path = require('pandoc.path')

-- local mediabag = require 'pandoc.mediabag' -- to be added later

-- LaTeX document templates
--  for display math we use \displaystyle 
--  see <https://tex.stackexchange.com/questions/50162/how-to-make-a-standalone-document-with-one-equation>
local inlinemath_template = [[
  \documentclass{standalone}
  %s
  \begin{document}
  $%s$
  \end{document}
]]
local displaymath_template = [[
  \documentclass{standalone}
  %s
  \begin{document}
  $\displaystyle
  %s$
  \end{document}
]]
local rawblock_template = [[
  \documentclass{standalone}
  \begin{document}
  %s
  \end{document}
]]
local rawinline_template = rawblock_template

-- templates for captions
local math_caption_template = "Math formula from LaTeX code: %s"
local raw_caption_template = "Element typeset from LaTeX code: %s"

-- options map
local options = {
  scope = 'selected', -- `selected`, `all`, `math`, `raw`, `none`
  exclude_formats = {'latex'}, -- default format to exclude
  do_something = true, -- false to deactivate the filter
  header = '' -- store for header-includes LaTeX code
}
local acceptable_scopes = pandoc.List:new(
  {'all', 'math', 'raw', 'none', 'selected'})

-- # Helper functions

--- message: send message to std_error
-- @param type string INFO, WARNING, ERROR
-- @param text string message text
function message(type, text)
    local level = {INFO = 0, WARNING = 1, ERROR = 2}
    if level[type] == nil then type = 'ERROR' end
    if level[PANDOC_STATE.verbosity] <= level[type] then
        io.stderr:write('[' .. type .. '] Pre-render lua filter: ' 
            .. text .. '\n')
    end
end

-- file_exists(name)
-- @param name  name of file
-- @return  boolean true if file exists, false otherwise
local function file_exists(name)
  local file = io.open(name, 'r')
  if file ~= nil then
    io.close(file)
    return true
  else
    return false
  end
end

-- # Main filter functions

-- math2image
-- converts raw math to image file using pdf2svg
-- @param source  raw math to be converted to image
-- @param filename  name of the output image file
local function math2image(source, filepath)
  system.with_temporary_directory('math2image', function (tmpdir)
    system.with_working_directory(tmpdir, function()
      local file = io.open('math.tex', 'w')
      file:write(source)
      file:close()
      pandoc.pipe('lualatex', {
        '--interaction=nonstopmode',
        '--output-format=pdf',
        'math.tex'
      }, '')
      pandoc.pipe('pdf2svg', {'math.pdf', filepath}, '')
      -- os.execute('lualatex --interaction=nonstopmode '
      --   .. '--output-format=' .. format .. ' ' 
      --   .. 'math.tex')
      -- os.execute('pdf2svg math.pdf ' .. filepath)
      -- os.execute('dvisvgm --optimize math.dvi ')
      -- os.execute('mv math.svg ' .. filepath)
    end)
  end)
end

-- pre_render_math: pre-renders a math element as image
-- unless we already have an image for that element's code
-- @param elem math element to be pre-rendered
local function pre_render(elem)

  -- if Raw, only process `latex` or `tex`
  if (elem.t == 'RawInline' or elem.t == 'RawBlock') 
    and not (elem.format == 'tex' or elem.format == 'latex') then
      return nil
  end

  local filepath = path.join( { 
    system.get_working_directory(), 
    pandoc.sha1(elem.text) .. '.svg'
  })
  if not file_exists(filepath) then
    -- build source 
    local source = ''
    if elem.t == 'Math' and elem.mathtype == 'DisplayMath' then
      source = displaymath_template:format(options.header, elem.text)
    elseif elem.t == 'Math' and elem.mathtype == 'InlineMath' then
      source = inlinemath_template:format(options.header, elem.text)
    elseif elem.t == 'RawBlock' then
      source = rawblock_template:format(elem.text)
    else -- RawInline
      source = rawinline_template:format(elem.text)
    end
    math2image(source, filepath)
  end
  -- build caption
  local caption = ''
  if elem.t == 'Math' then
    caption = math_caption_template:format(elem.text)
  else
    caption = raw_caption_template:format(elem.text)
  end
  -- return appropriate Pandoc element(s)
  if elem.t == 'Math' and elem.mathtype == 'DisplayMath' then
    return {pandoc.LineBreak(), pandoc.Image(caption, filepath), 
        pandoc.LineBreak()}
  elseif elem.t == 'Math' and elem.mathtype == 'InlineMath' then
    return pandoc.Image(caption, filepath)
  elseif elem.t == 'RawBlock' then
    return pandoc.Para({ pandoc.Image(caption, filepath) })
  else -- RawInline
    return pandoc.Image(caption, filepath)
  end
end

--- get_options: Get filter options from the document's metadata
-- @param meta Meta object
function get_options(meta)

  -- filter to complie tex header
  local compile_tex_header = function(elem)
      -- nb, LaTeX written directly in markdown is format `tex`
      -- LaTeX written within a native raw or span is format `latex`
      if elem.format == 'tex' or elem.format == 'latex' then
        options.header = options.header .. elem.text .. '\n'
      end
  end
  -- function to collect LaTeX code in a meta element
  -- and store it into `options.header`
  local collect_header_includes = function(meta_elem) 
    -- ensure it's a list
    if meta_elem.t ~= 'MetaList' then
      meta_elem = pandoc.MetaList({ meta_elem })
    end
    -- turn each item into a Div (pandoc.walk_block doesn't
    -- work on Meta elements), apply a filter that compiles
    -- header LaTeX code
    for _,item in ipairs(meta_elem) do
      local div = {}
      if item.t == 'MetaInlines' then
        div = pandoc.Div(pandoc.Plain(pandoc.List(item)))
      elseif item.t == 'MetaBlocks' then
        div = pandoc.Div(pandoc.List(item))
      end
      if div ~= {} then 
        pandoc.walk_block(div, {
          RawInline = compile_tex_header,
          RawBlock = compile_tex_header
        })
      end
    end
  end

  -- syntactic sugar: convert aliases to official
  -- conflict behaviour: the alias is used (as it may be provided
  -- on the command line to override the one specified in the document)
  local keys_with_aliases = {'scope', 'use-header'}
  for _,key in ipairs(keys_with_aliases) do
    if meta['pre-render-' .. key] ~= nil then
      -- warn if clash
      if not meta['pre-render'] then
        meta['pre-render'] = pandoc.MetaMap({
          key = meta['pre-render-' .. key]
          })
      elseif meta['pre-render'][key] == nil then
        meta['pre-render'][key] = meta['pre-render-' .. key]
      else
        message('WARNING', 'option `pre-render-' .. key .. '` replaces '
           .. 'the option `' .. key .. '` in `pre-render`.')
        meta['pre-render'][key] = meta['pre-render-' .. key]
      end
    end
  end

  -- `pre-render` map of options
  if meta['pre-render'] then

    -- ensure it's a map
    -- if not, we assume it's a `scope` option
    if meta['pre-render'].t ~= 'MetaMap' then 
      meta['pre-render'] = pandoc.MetaMap({
        scope = meta['pre-render']
      })
    end
    local opt_map = meta['pre-render']
    -- `scope`
    if opt_map.scope then
      if acceptable_scopes:find(pandoc.utils.stringify(opt_map.scope)) then
        options.scope = pandoc.utils.stringify(opt_map.scope)
      end
    end
    -- `exclude-formats`
    if opt_map['exclude-formats'] then
      options.exclude_formats = pandoc.List:new()
      -- ensure the value is a list
      if opt_map['exclude-formats'].t ~= 'MetaList' then
        opt_map['exclude-formats'] = pandoc.MetaList({ 
          opt_map['exclude-formats']
        })
      end
      -- insert each item as string
      for _,item in ipairs(opt_map['exclude-formats']) do
        options.exclude_formats:insert(pandoc.utils.stringify(item))
      end
      -- do nothing if the present output format is excluded
      for _,format in ipairs(options.exclude_formats) do
        if FORMAT:match(format) then 
          options.do_something = false
          break
        end
      end
    end
    -- `header-includes`: gather LaTeX
    if opt_map['header-includes'] then
      collect_header_includes(opt_map['header-includes'])
    end
  end

  -- metadata's `header-includes`: gather LaTeX
  if meta['header-includes'] and not (meta['pre-render'] 
    and meta['pre-render']['use-header'] == false) then
    collect_header_includes(meta['header-includes'])
  end

end

-- # Main set of filters
-- Get options, then apply the pre-render function to math 
-- and raw elements within selected divs
return {
  {
  Meta = get_options
  },
  {
    Div = function (element)
      if options.do_something then
          return pandoc.walk_block(element, {
            Math = pre_render,
            RawBlock = pre_render,
            RawInline = pre_render,
          })
      end
    end,
    Span = function (element)
      if options.do_something then
          return pandoc.walk_inline(element, {
            Math = pre_render,
            RawInline = pre_render,
          })
      end
    end,
  }

}