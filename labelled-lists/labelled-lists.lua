--[[-- # Labelled-lists - custom labelled lists
 in Pandoc's markdown.

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2021 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.2

@TODO style the HTML output
@TODO in HTML, leave the BulletList element as is. 
      simply turn the Spans into labels, and wrap in a Div. 
@TODO style the label in all outputs
@TODO Possible solution: first sytle all labels, leaving 
    the pandoc.BulletList as is. Then send it to a formatter
    that wraps it in a Div (html) and adds local CSS style 
    block if needed, or flattens it in Raw for LaTeX.  
@TODO use a Div to declare as custom-label list
]]

-- # Internal settings

--- Options map, including defaults.
-- @disable_citations boolean whether to use pandoc-crossref cite syntax
-- @delimiter list label delimiters (as a list)
local options = {
    disable_citations = false,
    delimiter = {'(',')'},
}

-- target_formats  filter is triggered when those formats are targeted
local target_formats = {
  "html.*",
  "latex",
  "jats",
}

-- html classes
local html_classes = {
    item = 'labelled-lists-item',
    label = 'labelled-lists-label',
    list = 'labelled-lists-list',
}

-- Css to be used later
local Css = [[
div.labelled-list > ul {
  list-style-type: none;
}
div.labelled-list > ul li {
/*  border: 1px solid dimgray;*/
  padding-left: 1em;
}
div.labelled-list > ul > li > label:first-child{
/*  border: 1px solid blue;*/
  display: inline-block;
  min-width: 3em; /* 2em + padding on li */
  margin-left: -3.5em; /* -(2.5em + padding on li) */
  margin-right: .5em;
  color: blue;
}
div.labelled-list > ul > li > *:first-child > label:first-child{
/*  border: 1px solid red;*/
  display: inline-block;
  min-width: 3em; /* 2em + padding on li */
  margin-left: -3.5em; /* -(2.5em + padding on li) */
  margin-right: .5em;
  color: red;
}
]]

-- # Global variable

-- table of indentified labels
local labels_by_id = {}

-- # Helper functions

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

--- format_matches: Test whether the target format is in a given list.
-- @param formats list of formats to be matched
-- @return true if match, false otherwise
function format_matches(formats)
  for _,format in pairs(formats) do
    if FORMAT:match(format) then
      return true
    end
  end
  return false
end

--- message: send message to std_error
-- @param type string INFO, WARNING, ERROR
-- @param text string text of the message
function message(type, text)
    local level = {INFO = 0, WARNING = 1, ERROR = 2}
    if level[type] == nil then type = 'ERROR' end
    if level[PANDOC_STATE.verbosity] <= level[type] then
        io.stderr:write('[' .. type .. '] Labelled-lists lua filter: ' 
            .. text .. '\n')
    end
end

-- # Filter functions

--- filter_citations: process citations to labelled lists
-- Check whether the Cite element only contains references to custom 
-- label items, and if it does, convert them to crossreferences.
-- @param cite pandoc AST Cite element
function filter_citations(cite)

    -- warn if the citations mix cross-label references with 
    -- standard ones
    local has_cl_ref = false
    local has_biblio_ref = false

    for _,citation in ipairs(cite.citations) do
        if labels_by_id[citation.id] then
            has_cl_ref = true
        else
            has_biblio_ref = true
        end
    end

    if has_cl_ref and has_biblio_ref then
        message('WARNING', 'A citation mixes bibliographic references \
            with custom label references '
            .. pandoc.utils.stringify(cite.content) )
        return
    end

    if has_cl_ref and not has_biblio_ref then

        -- get style from the first citation
        local bracketed = true 
        if cite.citations[1].mode == 'AuthorInText' then
            bracketed = false
        end

        local inlines = pandoc.List:new()

        -- create link(s)

        for i = 1, #cite.citations do
           inlines:insert(pandoc.Link(
                labels_by_id[cite.citations[i].id],
                '#' .. cite.citations[i].id
            ))
            -- add separator if needed
            if #cite.citations > 1 and i < #cite.citations then
                inlines:insert(pandoc.Str('; '))
            end
        end


        if bracketed then
            inlines:insert(1, pandoc.Str('('))
            inlines:insert(pandoc.Str(')'))
        end

        return inlines

    end

end

--- filter_links: process internal links to labelled lists
-- Empty links to a custom label are filled with the custom
-- label text. 
-- @param element pandoc AST link
-- @TODO in LaTeX output you need \ref and \label
function filter_links (link)

    if pandoc.utils.stringify(link.content) == '' 
        and link.target:sub(1,1) == '#' 
        and labels_by_id[link.target:sub(2,-1)] then

        link.content = labels_by_id[link.target:sub(2,-1)]
            return link

    end

end

-- style_label: style the label
-- returns a styled label. Default: round brackets
-- @param label Inlines an item's label as list of inlines
-- @param delim (optional) a pair of delimiters (list of two strings)
-- @return pandoc.Inlines label
function style_label(label, delim)
    if not delim then
        delim = options.delimiter
    end
    styled_label = label:clone()
    styled_label:insert(1, pandoc.Str(delim[1]))
    styled_label:insert(pandoc.Str(delim[2]))
    return styled_label
end

--- build_list: processes a custom label list
-- returns a list of blocks containing Raw output format code
-- @param element BulletList the original Bullet List element
function build_list(element)

    -- build a list of blocks
    local list = pandoc.List:new()

    -- start

    if FORMAT:match('latex') then
        list:insert(pandoc.RawBlock('latex',
            '\\begin{itemize}\n\\tightlist'
            ))
    elseif FORMAT:match('html') then
        list:insert(pandoc.RawBlock('html',
            '<div class="' .. html_classes['list'] .. '">'
            ))
    end

    -- does the first span have a delimiter attribute?
    -- element.c[1] is the first item in the list, type blocks
    -- .. [1].c is the first block's content, type inlines
    -- .. [1] the first inline in that block, our span
    local span = element.c[1][1].c[1]
    local delim = nil
    if span.attributes and span.attributes.delimiter then
        delim = read_delimiter(span.attributes.delimiter)
    end

    -- process each item

    for _,blocks in ipairs(element.c) do

        -- get the span, remove it from the tree, store its content
        local span = blocks[1].c[1]
        blocks[1].c:remove(1)
        local label = pandoc.List(span.content)
        local id = ''

        -- get identifier if not duplicate, store a copy in global table
        if not (span.identifier == '') then
            if labels_by_id[span.identifier] then
                message('WARNING', 'duplicate item identifier ' 
                    .. span.identifier .. '. The second is ignored.')
            else
                labels_by_id[span.identifier] = label
                id = span.identifier
            end
        end

        if FORMAT:match('latex') then

            local inlines = pandoc.List:new()
            inlines:insert(pandoc.RawInline('latex','\\item['))
            inlines:extend(style_label(label, delim))
            inlines:insert(pandoc.RawInline('latex',']'))
            -- create link target if needed
            if not(id == '') then 
                inlines:insert(pandoc.Span('', {id = id}))
            end            

            -- if the first block is Plain or Para, we insert
            -- the label code at the beginning
            -- otherwise we add a Plain block for the label
            if blocks[1].t == 'Plain' or blocks[1].t == 'Para' then
                inlines:extend(blocks[1].c)
                blocks[1].c = inlines
                list:extend(blocks)
            else
                list:insert(pandoc.Plain(inlines))
                list:extend(blocks)
            end

        elseif FORMAT:match('html') then

            local label_span = pandoc.Span(style_label(label, delim))
            label_span.classes = { html_classes['label'] }
            if id then label_span.identifier = id end

            -- if there is only one block and it's Plain or Para,
            -- we create the item as <p>, otherwise as <div>
            if #blocks == 1 and 
                (blocks[1].t == 'Plain' or blocks[1].t == 'Para') then
                    local inlines = pandoc.List:new()
                    inlines:insert(1, pandoc.RawInline('html', 
                        '<p class="' .. html_classes['item'] .. '">'))
                    inlines:insert(label_span)
                    inlines:extend(blocks[1].c)
                    inlines:insert(pandoc.RawInline('html', '</p>'))
                    list:insert(pandoc.Plain(inlines))
            else
                -- if the first block is Plain or Para we insert the
                -- label in it, otherwise the label is its own paragraph
                if (blocks[1].t == 'Plain' or blocks[1].t == 'Para') then
                    local inlines = pandoc.List:new()
                    inlines:insert(label_span)
                    inlines:extend(blocks[1].c)
                    blocks[1].c = inlines
                else
                    blocks:insert(1, pandoc.Para(label_span))
                end

                list:insert(pandoc.Div(blocks,  
                    { class = html_classes['item'] } ))        

            end
 
        end

    end

    if FORMAT:match('latex') then
        list:insert(pandoc.RawBlock('latex',
            '\\end{itemize}\n'
            ))
    elseif FORMAT:match('html') then
        list:insert(pandoc.RawBlock('html','</div>'))        
    end

    return list
end

--- is_custom_labelled_list: Look for custom labels markup
-- Custom label markup requires each item starting with a span
-- containing the label
-- @param element pandoc BulletList element
function is_custom_labelled_list (element)

    local is_cl_list = true

    -- the content of BulletList is a List of List of Blocks
    for _,blocks in ipairs(element.c) do

        -- check that the first element of the first block is Span
        -- ~~and not empty~~ allowing empty
        if not( blocks[1].c[1].t == 'Span' ) 
            -- or pandoc.utils.stringify(blocks[1].c[1].content) == '' 
            then
            is_cl_list = false
            break 
        end
    end

    return is_cl_list
end

--- read_delimiter: process a delimiter option
-- @delim: string, e.g. `Parens` or `[%1]`
-- @return: a pair of delimiter strings
function read_delimiter(delim) 
    delim = pandoc.utils.stringify(delim)

    --- process standard Pandoc attributes and their equivalent
    if delim == '' or delim:lower() == 'none' then
        return {'',''}
    elseif delim == 'Period' or delim == '.' then
        return {'', '.'}
    elseif delim == 'OneParen' or delim == ')' then
        return {'', ')'}
    elseif delim == 'TwoParens' or delim == '(' or delim == '()' then
        return {'(',')'}
    --- if it contains '%1' assume it's a substitution string for gmatch
    -- the left delimiter is before '%1' and the right after
    elseif string.find(delim, '%%1') then
        return {delim:match('^(*.)%%1') or '', 
                delim:match('%%1(*.)$') or ''}
    end

end

--- Read options from metadata block.
--  Get options from the `statement` field in a metadata block.
-- @todo read kinds settings
-- @param meta the document's metadata block.
-- @return nothing, values set in the `options` map.
-- @see options
function get_options(meta)
  if meta['labelled-lists'] then

    if meta['labelled-lists']['disable-citations'] then
        options.disable_citations = true
    end


    -- default-delimiter: string
    if meta['labelled-lists'].delimiter and 
            type(meta['labelled-lists'].delimiter) == 'Inlines' then
        local delim = read_delimiter(pandoc.utils.stringify(
                        meta['labelled-lists'].delimiter))
        if delim then options.delimiter = delim end
    end

  end
end

-- # Filter

--- Main filters: read options, process lists, process crossreferences
read_options_filter = {
    Meta = get_options
}
process_lists_filter = {
    BulletList = function(element)
        if is_custom_labelled_list(element) then
            return build_list(element)
        end
    end,
}
crossreferences_filter = {
    Link = filter_links,
    Cite = function(element) 
        if not options.disable_citations then 
            return filter_citations(element)
        end
    end
}


--- Main code
-- return the filters in the desired order
if format_matches(target_formats) then
    return { read_options_filter, 
        process_lists_filter, 
        crossreferences_filter
    }
end
