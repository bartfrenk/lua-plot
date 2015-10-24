-- luacheck: globals Utils
-- luacheck: globals type mapToStr isPositiveInt Base makeString isBoundedInt
Utils = {}
local globalType = type
local pcall = pcall
local pairs = pairs
local table = table
local getmetatable = getmetatable
local setmetatable = setmetatable
setfenv(1, Utils)

function type(x)
  local mt = getmetatable(x)
  if (mt and mt.__type) then
    return mt.__type
  else
    return globalType(x)
  end
end

function makeString(self)
  return type(self)..": {"..mapToStr(self).."}"
end

function mapToStr(map)
  local strings = {}
  local success
  local str
  for key, value in pairs(map) do
    -- allow value to be non-printable
    success, str = pcall(function() return key..": "..value end)
    if success then
      table.insert(strings, str)
    end
  end
  return table.concat(strings, ", ")
end

function isPositiveInt(x)
  if (type(x) ~= "number") then
    return false
  end
  return (x % 1 == 0) and (x > 0)
end

function isBoundedInt(x, interval)
  if (type(x) ~= "number") then
    return false
  end
  return (x % 1 == 0 and interval[1] <= x and interval[2] <= x)
end

Base = {}
Base.__tostring = tostring

function Base:create()
  local instance = {}
  setmetatable(instance, self)
  self.__index = self
  self.__type = "Base"
  return instance
end
