local lb = require "luabalanced"

-- Extract Lua expression starting at position 4.
print(lb.match_expression("if x^2 + x > 5 then print(x) end", 4))
--> x^2 + x > 5     16

-- Extract Lua string starting at (default) position 1.
print(lb.match_string([["test\"123" .. "more"]]))
--> "test\"123"     12

-- Break Lua code into code types.
lb.gsub([[
  local x = 1  -- test
  print("x=", x)
]], function(u, s)
  print(u .. '[' .. s .. ']')
end)
--[[output:
e[  local x = 1  ]
c[-- test
]
e[  print(]
s["x="]
e[, x)
]
]]
