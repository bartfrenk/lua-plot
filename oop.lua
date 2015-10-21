-- luacheck: globals Base Plot Canvas Frame type

-- TODO: put utility functions in seperate file and namespace

Plot = {}
local setmetatable = setmetatable
local pcall = pcall
local pairs = pairs
local error = error
local table = table
local globalType = type
local getmetatable = getmetatable
setfenv(1, Plot)

function type(x)
  local mt = getmetatable(x)
  if (mt and mt.__type) then
    return mt.__type
  else
    return globalType(x)
  end
end

local function mapToStr(map)
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

local function affineMap(from, to)
  local function fn(x)
    local slope = (to[2] - to[1]) / (from[2] - from[1])
    local intercept = to[1] - slope * from[1]
    return slope * x + intercept
  end
  return fn
end

local function intervalToStr(interval)
  return "["..interval[1]..", "..interval[2].."]"
end

local function isPositiveInt(x)
  if (type(x) ~= "number") then
    return false
  end
  return (x % 1 == 0) and (x > 0)
end

local function isInterval(x)
  if (type(x) ~= "table") then
    return false
  end
  return (#x == 2 and type(x[1]) == "number" and type(x[2]) == "number")
end

local function tostring(self)
  return type(self)..": {"..mapToStr(self).."}"
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

Canvas = Base:create()
Canvas.__tostring = tostring

function Canvas:create(width, height, rows, columns)
  rows = rows or 1
  columns = columns or 1
  if not isPositiveInt(width) or not isPositiveInt(height) then
    error("Width and height need to be positive integers")
  elseif not isPositiveInt(rows) or not isPositiveInt(columns) then
    error("Rows and columns need to be positive integers")
  end
  local instance = {width = width, height = height, rows = rows, columns = columns}
  setmetatable(instance, self)
  self.__index = self
  self.__type = "Canvas"
  return instance
end

function Canvas:frame(domain, range, row, column)
  domain = domain or {0, 1}
  range = range or {0, 1}
  row = row or 1
  column = column or 1
  -- change to isBoundedInt
  if not isPositiveInt(row) or not isPositiveInt(column) or row > self.rows or column > self.columns then
    error("Frame does not exist")
  end
  if (not isInterval(domain) or not isInterval(range)) then
    error("Domain and range should be intervals")
  end
  return Frame:create(self, domain, range, row, column)
end

function Canvas:pixelWidthRange(column)
  local columnWidth = self.width / self.columns
  return {(column - 1) * columnWidth, column * columnWidth}
end

function Canvas:pixelHeightRange(row)
  local rowHeight = self.height / self.rows
  return {row * rowHeight, (row - 1) * rowHeight}
end

Frame = Base:create()

function Frame:create(canvas, domain, range, row, column)
  -- TODO: check arguments
  local widthMap = affineMap(domain, canvas:pixelWidthRange(column))
  local heightMap = affineMap(range, canvas:pixelHeightRange(row))

  -- optimization: with canvas maps and ranges are functions of each other
  local instance = {parent = canvas, row = row, column = column,
                    widthMap = widthMap, heightMap = heightMap,
                    domain = domain, range = range}
  setmetatable(instance, self)
  self.__index = self
  self.__type = "Frame"
  return instance
end

function Frame:__tostring()
  local str = "domain: "..intervalToStr(self.domain)..", "..
              "range: "..intervalToStr(self.range)
  return type(self)..": {"..mapToStr(self)..", "..str.."}"
end
