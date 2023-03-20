--- secnumdepth.lua
--- enables secnumdepth in formats other than LaTeX
--- see https://github.com/jgm/pandoc/issues/6459

stringify = pandoc.utils.stringify

secnumdepth = 6


function readMeta(meta)
  secnumdepth = meta.secnumdepth and tonumber(stringify(meta.secnumdepth))
    or secnumdepth
end

function processHeader (h)
  if h.level > secnumdepth then 
    h.classes:insert 'unnumbered'
    return h
  end
end

if not FORMAT:match('latex') then 
    return {
        { Meta = readMeta },
        { Header = processHeader }
    }
end