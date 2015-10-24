-- luacheck: globals Plot Canvas Frame

-- TODO: remove dependence on absolute path
package.path = package.path..';/home/bart/documents/projects/lua-experiments/?.lua'
dofile "utils.lua"


Plot = {_G = _G}
-- luacheck: push
-- luacheck: ignore Utils
local Base = Utils.Base
local isPositiveInt = Utils.isPositiveInt
local isBoundedInt = Utils.isBoundedInt
local makeString = Utils.makeString
local mapToStr = Utils.mapToStr
local type = Utils.type
-- luacheck: pop

local setmetatable = setmetatable
local error = error

_G.setfenv(1, Plot)

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

local function isInterval(x)
  if (type(x) ~= "table") then
    return false
  end
  return (#x == 2 and type(x[1]) == "number" and type(x[2]) == "number")
end

Canvas = Base:create()
Canvas.__tostring = makeString

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
  if not isBoundedInt(row, {1, self.rows}) or not isBoundedInt(column, {1, self.columns}) then
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
  local domainMap = affineMap(domain, canvas:pixelWidthRange(column))
  local rangeMap = affineMap(range, canvas:pixelHeightRange(row))

  -- optimization: with canvas maps and ranges are functions of each other
  local instance = {parent = canvas, row = row, column = column,
                    domainMap = domainMap, rangeMap = rangeMap,
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

_G.setfenv(1, _G)

local function test()
  local canvas = Plot.Canvas:create(10, 10)
  print(canvas)
  local frame = canvas:frame()
  print(frame)
end

test()
