--- needed in Pandoc < 2.17

---@alias metaObject
---| boolean
---| string
---| pandoc.MetaMap
---| pandoc.MetaInlines
---| pandoc.MetaBlocks
---| pandoc.List

---@alias typeName 'boolean'|'string'|'table'|'Inlines'|'Blocks'|'List'|'nil'

--- get the type of meta object (h/t Albert Krewinkel)
---@type fun(obj: metaObject): typeName
local metatype = pandoc.utils.type or
  function (obj)
    local metatag = type(obj) == 'table' and obj.t and obj.t:gsub('^Meta', '')
    return metatag and metatag ~= 'Map' and metatag or type(obj)
  end