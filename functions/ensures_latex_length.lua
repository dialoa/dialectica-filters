--[[
# ensures_latex_length(text)

Ensures that `text` declares a latex length

returns text if it is or `nil` if it isn't
]]
local function ensures_latex_length(text)
  
  -- LaTeX lengths units
  --  nb, % must be escaped in lua patterns
  units = { '%%', 'pt', 'mm', 'cm', 'in', 'ex', 'em' }
  
  local result = nil
  
  -- ignore spaces, controls and punctuation other than
  -- dot, plus, minus
  text = string.gsub(text, "[%s%c,;%(%)%[%]%*%?%%%^%$]+", "")
  
  for _,unit in pairs(units) do
    
    -- match .11em format and 1.2em format
    if string.match(text, '^%.%d+'.. unit .. '$') or
      string.match(text, '^%d+%.?%d*'.. unit .. '$') then
        
      result = text
        
    end
        
  end
 
  return result
end
