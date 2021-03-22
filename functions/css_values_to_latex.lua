--[[
# css_values_to_latex(css_str)

converts CSS values in `string` into LaTeX values

string 
: string specifying CSS values, e.g. "3px solid black"

returns a table with keys `length`, `color` (and `colour`) if found
]]
local function css_values_to_latex(css_str)
    
  -- color conversion table
  --  keys are CSS values, values are LaTeX equivalents
  
  latex_colors = {
    -- xcolor always available
    black = 'black',
    blue = 'blue',
    brown = 'brown',
    cyan = 'cyan',
    darkgray = 'darkgray',
    gray = 'gray',
    green = 'green',
    lightgray = 'lightgray',
    lime = 'lime',
    magenta = 'magenta',
    olive = 'olive',
    orange = 'orange',
    pink = 'pink',
    purple = 'purple',
    red = 'red',
    teal = 'teal',
    violet = 'violet',
    white = 'white',
    yellow = 'yellow',
    -- css1 colors
    silver = 'lightgray',
    fuschia = 'magenta',
    aqua = 'cyan',    
  }
  
  local result = {}
  
  -- look for color values
  --  by color name
  --  rgb, etc.: to be added
  
  local color = ''

  -- space in front simplifies pattern matching
  css_str = ' ' .. css_str

  for text in string.gmatch(css_str, '[%s](%a+)') do
    
    -- if we have LaTeX equivalent of `text`, store it
    if latex_colors[text] then
      result['color'] = latex_colors[text] 
    end
    
  end
  
  -- provide British spelling
  
  if result['color'] then
    result['colour'] = result['color']
  end  
  
  -- look for lengths
  
  --  0 : converted to 0em
  if string.find(css_str, '%s0%s') then
   result['length'] = '0em'
  end
  
  --  px : converted to pt
  for text in string.gmatch(css_str, '(%s%d+)px') do
   result['length'] = text .. 'pt'    
  end
  
  -- lengths units to be kept as is
  --  nb, % must be escaped
  --  nb, if several found, the latest type is preserved
  keep_units = { '%%', 'pt', 'mm', 'cm', 'in', 'ex', 'em' }
  
  for _,unit in pairs(keep_units) do
    
    -- .11em format
    for text in string.gmatch(css_str, '%s%.%d+'.. unit) do
      result['length'] = text
    end

    -- 2em and 1.2em format
    for text in string.gmatch(css_str, '%s%d+%.?%d*'.. unit) do
      result['length'] = text
    end
    
  end

  return result

end
