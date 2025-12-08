--[[-- # LaTeX-fixes - Pandoc/Quarto filter for common LaTeX fixes

@author Julien Dutant https://github.com/jdutant
@copyright 2025 Philosophie.ch https://github.com/Philosphie-ch
@license MIT - see LICENSE file for details.
@release 0.1

]]

type = pandoc.utils.type

---note: fix footnotes
---If a footnote ends by a quote, add blank space.
---@param el pandoc.Note
function note(el)
    local changed = false

    if #el.content > 0 
    and el.content:at(-1).t == 'BlockQuote' then
        el.content:insert(
            pandoc.RawInline('latex','\\vspace{0em}')
        )
        changed = true
    end

    if changed then return el end
end


if FORMAT:match('latex') then 
    return{
        {
            Note = note,
        }
    }
else
    return {{}}
end