--[[-- # First-line-indent - First-line idented paragraphs
 in Pandoc's markdown.

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2021 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.1
]]

-- # Options

--- Options map, including defaults.
-- @param set_metadata_variable boolean whether to set the `indent`
--    metadata variable.
-- @param set_header_includes boolean whether to add formatting code in
--    header-includes to handle first-line indent paragraph style.
-- @param auto_remove_indents boolean whether to automatically remove
--    indents after blockquotes and the like.
-- @param remove_after list of strings, Pandoc AST block types
--    after which first-line indents should be automatically removed.
-- @param remove_after_class list of strings, classes of elements
--    after which first-line indents should be automatically removed.
-- @param dont_remove_after_class list of strings, classes of elements
--    after which first-line indents should not be removed. Prevails
--    over remove_after.
-- @param size string a CSS / LaTeX specification of the first line
--    indent length
local options = {
  set_metadata_variable = true,
  set_header_includes = true,
  auto_remove = true,
  remove_after = pandoc.List({
    'BlockQuote',
    'BulletList',
    'CodeBlock',
    'DefinitionList',
    'HorizontalRule',
    'OrderedList',
  }),
  remove_after_class = pandoc.List({
    'statement', 'argument',
  }),
  dont_remove_after_class = pandoc.List:new(),
  size = "1em",
}
-- List of pandoc AST block elements that have classes
local types_with_classes = pandoc.List({
  'CodeBlock', 'Div', 'Header', 'Table', 
})

-- # Filter global variables
-- @utils pandoc's module of utilities functions
-- @param code map of pandoc objects for indent/noindent Raw code
-- @param header_code map of pandoc code to add to header-includes
local utils = pandoc.utils
local code = {
  latex = {
    indent = pandoc.RawInline('tex', '\\indent '),
    noindent = pandoc.RawInline('tex', '\\noindent '),
  },
  html = {
    indent = pandoc.RawBlock('html',
      '<div class="first-line-indent-after"></div>'),
    noindent = pandoc.RawBlock('html',
      '<div class="no-first-line-indent-after"></div>'),
  }
}
local header_code = {
  html = [[
  <style>
    p {
      text-indent: SIZE;
      margin: 0;
    }
    header + p {
      text-indent: ;
    }
    :is(h1, h2, h3, h4, h5, h6) + p {
      text-indent: 0;
    }
    :is(div.no-first-line-indent-after) + p {
      text-indent: 0;
    }
    :is(div.first-line-indent-after) + p {
      text-indent: SIZE;
    }
  </style>
]],
}

--- add_header_includes: add a block to the document's header-includes 
-- meta-data field.
-- @param meta the document's metadata block
-- @param blocks list of Pandoc block elements (e.g. RawBlock or Para)
--    to be added to the header-includes of meta
-- @return meta the modified metadata block
local function add_header_includes(meta, blocks)

  local header_includes = pandoc.MetaList( { pandoc.MetaBlocks(blocks) })

  -- add any exisiting meta['header-includes']
  -- it can be MetaInlines, MetaBlocks or MetaList
  if meta['header-includes'] then
    if meta['header-includes'].t == 'MetaList' then
      header_includes:extend(meta['header-includes'])
    else
      header_includes:insert(meta['header-includes'])
    end
  end

  meta['header-includes'] = header_includes

  return meta

end

--- classes_include: check if one of an element's class is in a given
-- list. Returns true if match, nil if no match or the element doesn't 
-- have classes.
-- @param elem pandoc AST element
-- @param classes pandoc List of strings
local function classes_include(elem,classes)

  if elem.classes then 

    for _,class in ipairs(elem.classes) do
      if classes:includes(class) then return true end
    end

  end

end

-- # Filter functions


--- Filter for the metablock.
-- reads the user options.
-- sets the metadata variable `indent` to `true` unless otherwise specified.
-- adds formatting code to `header-includes` unless otherwise specified.
function process_metadata(meta)

  -- read user options
  if meta['first-line-indent'] then

    local user_options = meta['first-line-indent']

    if not(user_options['set-metadata-variable'] == nil)
      and user_options['set-metadata-variable'] == false then
      options.set_metadata_variable = false

    end

    if not(user_options['set-header-includes'] == nil)
      and user_options['set-header-includes'] == false then
      options.set_header_includes = false
    end

    if not(user_options['auto-remove'] == nil)
      and user_options['auto-remove'] == false then
      options.auto_remove = false
    end

    -- (dont-)remove-after, (dont-)remove-after-class accept only 
    -- MetaInlines and MetaList, we standardize to the latter
    for _,key in ipairs({'remove-after','dont-remove-after',
                  'remove-after-class','dont-remove-after-class'}) do
      if user_options[key] and user_options[key].t == 'MetaInlines' then
        user_options[key] = pandoc.MetaList({user_options[key]})
      end
    end

    -- for object types we only need to customize one list, remove_after
    -- for classes we need a whitelist (remove_after_class) and a
    -- blacklist (dont_remove_after_class). 
    -- We first insert user entries in remove_after, remove_after_class
    -- and dont_remove_after_class.
    for optname, metakey in pairs({
        remove_after = 'remove-after',
        remove_after_class = 'remove-after-class',
        dont_remove_after_class = 'dont-remove-after-class',
      }) do

      if user_options[metakey] 
        and user_options[metakey].t == 'MetaList' then

          for _,item in ipairs(user_options[metakey]) do

            options[optname]:insert(utils.stringify(item))

          end

      end

    end

    -- We then remove user entries from remove_after and remove_after_class
    for optname, metakey in pairs({
        remove_after = 'dont-remove-after',
        remove_after_class = 'dont-remove-after-class'
      }) do

      if user_options[metakey] 
        and user_options[metakey].t == 'MetaList' then

        -- list of strings to be removed
        local blacklist = pandoc.List:new()

        for _,item in ipairs(user_options[metakey]) do

          blacklist:insert(utils.stringify(item))

        end

        -- filter to that returns true iff an item isn't blacklisted
        predicate = function (str)
            return not(blacklist:includes(str))
          end

        options[optname] =
          options[optname]:filter(predicate)

      end

    end

   -- sil
   if not(user_options['size'] == nil) then

      -- @todo using stringify means that LaTeX commands in
      -- size are erased. But it ensures that the filter gets
      -- a string. Improvement: check that we have a string
      -- and throw a warning otherwise
      options.size = utils.stringify(user_options['size'])

    end

  end

  -- variable to track whether we've changed `meta`
  changes = false

  -- set the `indent` metadata variable unless otherwise specified or
  -- already set to false
  if options.set_metadata_variable and not(meta.indent == false) then
    meta.indent = true
    changes = true
  end

  -- set the `header-includes` metadata variable
  if options.set_header_includes then

    if FORMAT:match('html*') then

      header_code.html = string.gsub(header_code.html, "SIZE", options.size)
      add_header_includes(meta, { pandoc.RawBlock('html', header_code.html) })

    elseif FORMAT:match('latex') and not(options.size == "1em") then

      add_header_includes(meta, { pandoc.RawBlock('tex',
        '\\setlength{\\parindent}{'.. options.size ..'}') })

    end

  end

  if changes then return meta end

end

--- Add format-specific explicit indent markup to a paragraph.
-- @param type string 'indent' or 'noindent', type of markup to add
-- @param elem pandoc AST paragraph
-- @return a list of blocks (containing a single paragraph element or
-- a rawblock and a paragraph element, depending on output format)
local function indent_markup(type, elem)

  if FORMAT:match('latex') and (type == 'indent' or type == 'noindent') then

    -- in LaTeX, replace any `\indent` or `\noindent` command at
    -- the start of the paragraph with the desired one, add it otherwise

    local content = pandoc.List(elem.content)

    if content[1] and (utils.equals(content[1],
        code.latex.indent) or utils.equals(content[1],
        code.latex.noindent)) then

      content[1] = code.latex[type]

    else

      content:insert(1, code.latex[type])

    end

    elem.content = content
    return({ elem })

  -- in HTML, insert a block (div) before the paragraph

  elseif FORMAT:match('html*') and (type == 'indent' or type == 'noindent') then

    return({ code.html[type], elem })

  else

    return({elem})

  end

end

--- Process indents in the document's body text.
-- Adds output code for explicitly specified first-line indents,
-- automatically removes first-line indents after blocks of the
-- designed types unless otherwise specified.
local function process_body(doc)

  -- result will be the new doc.blocks
  local result = pandoc.List({})
  local do_not_indent_next_block = false

  for _,elem in pairs(doc.blocks) do

    -- Paragraphs may already have explicit indentation marking
    -- in LaTeX. If so we reproduce it in the relevant output
    -- format. Otherwise we remove the first-line indent if 
    -- needed, provided auto_remove is on.
    if elem.t == "Para" then

      if elem.content[1] and (utils.equals(elem.content[1],
        code.latex.indent) or utils.equals(elem.content[1],
        code.latex.noindent)) then

        if utils.equals(elem.content[1], code.latex.indent) then
          result:extend(indent_markup('indent', elem))
        else
          result:extend(indent_markup('noindent', elem))
        end

      elseif do_not_indent_next_block and options.auto_remove then

        result:extend(indent_markup('noindent', elem))

      else

        result:insert(elem)

      end

      do_not_indent_next_block = false

    -- if not paragraph, we check if it is an element after which
    -- first-line should be removed because of its type or class
    elseif options.remove_after:includes(elem.t) and 
       not classes_include(elem, options.dont_remove_after_class) then
 
      do_not_indent_next_block = true
      result:insert(elem)

    elseif types_with_classes:includes(elem.t) and 
      classes_include(elem, options.remove_after_class) then

      do_not_indent_next_block = true
      result:insert(elem)

    -- otherwise we don't remove indent after this block
    else

      do_not_indent_next_block = false
      result:insert(elem)

    end

  end

  doc.blocks = result
  return doc

end

--- Main code
-- Returns the filters in the desired order of execution
local metadata_filter = {
  Meta = process_metadata
}
local body_filter = {
  Pandoc = process_body
}
return {
  metadata_filter,
  body_filter
}
