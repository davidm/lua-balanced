-- tuple.lua
-- Simple tuple implementation using tables.
-- (c) 2008, David Manura, Licensed under the same terms as Lua (MIT license).

local select = select
local tostring = tostring
local setmetatable = setmetatable
local table_concat = table.concat

local mt = {}
local function tuple(...)
  local t = setmetatable({n=select('#',...), ...}, mt)
  return t
end
function mt:__tostring()
  local ts = {}
  for i=1,self.n do local v = self[i]
    ts[#ts+1] = type(v) == 'string' and string.format('%q', v) or tostring(self[i])
  end
  return 'tuple(' .. table_concat(ts, ',') .. ')'
end
function mt.__eq(a, b)
  if a.n ~= b.n then return false end
  for i=1,a.n do
    if a[i] ~= b[i] then return false end
  end
  return true
end

return tuple

