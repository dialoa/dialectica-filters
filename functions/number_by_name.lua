--[[
# number_by_name(name)

name (string)
: name of the number (e.g. "one")

returns the number corresponding to the name
]]
local function number_by_name(name)
  
  local names = {
    one = 1,
    two = 2,
    three = 3,
    four = 4,
    five = 5,
    six = 6,
    seven = 7,
    eight = 8,
    nine = 9,
    ten = 10,
    first = 1,
    second = 2,
    third = 3,
    fourth = 4,
    fifth = 5,
    sixth = 6,
    seventh = 7,
    eighth = 8,
    ninth = 9,
    tenth = 10,
  }
  
  result = nil
  
  if name then
    if names[name] then 
      return names[name] 
    end
  end
  
end
