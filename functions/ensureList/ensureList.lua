--- think of using metatype rather than type
--- this is only used for Meta elements

--- ensure meta element is a (possibly empty) pandoc.List
---@param obj metaObject
---@return pandoc.List obj
local function ensureList(obj)
  return obj ~=nil and (
      type(obj) == 'List' and obj or pandoc.List(obj)
    ) or pandoc.List:new()
end
