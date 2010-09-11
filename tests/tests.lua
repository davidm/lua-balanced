-- luabalanced_test.lua
-- test for luabalanced.lua 

package.path = package.path .. ';tests/?.lua'

local lb = require "luabalanced"
local tuple = require "tuple"

-- utility function for test suite.
local function asserteq(a, b)
  if a ~= b then
    error(tostring(a) .. ' == ' .. tostring(b) .. ' failed', 2)
  end
end

-- utility function (wrap function: store return in tuple and protect)
local function wrap2(f)
  return function(s, pos)
    local res = tuple(pcall(function() return f(s, pos) end))
    if not res[1] then
      return 'error'
    else
      return tuple(unpack(res, 2, res.n))
    end
  end
end

--## match_bracketed tests

-- test wrapper for lb.match_bracketed
local mb = wrap2(lb.match_bracketed)

-- trivial tests
asserteq(mb'', tuple(nil, 1))
asserteq(mb'a', tuple(nil, 1))
asserteq(mb'{', 'error')
asserteq(mb'}', tuple(nil, 1))
asserteq(mb'{[}]', 'error')
asserteq(mb('[{}]'), tuple('[{}]', 5))

-- test with pos
asserteq(mb('[][a(a)a].', 3), tuple('[a(a)a]', 10))

-- test with strings
asserteq(mb('[ "]" ]'), tuple('[ "]" ]', 8))
asserteq(mb("[ '[' ]"), tuple("[ '[' ]", 8))
asserteq(mb("[ [=[ ]=] ]"), tuple("[ [=[ ]=] ]", 12))
asserteq(mb("[[ ] ]]"), tuple("[[ ] ]]", 8))
asserteq(mb("[=[ [ ]=]"), tuple("[=[ [ ]=]", 10))

--## match_expression tests

-- test wrapper for lb.match_expression
local me = wrap2(lb.match_expression)
asserteq(me'a', tuple('a', 2))
asserteq(me'a b=c', tuple('a ', 3))
asserteq(me'a and b', tuple('a and b', 8))
asserteq(me'a and b ', tuple('a and b ', 9))
asserteq(me'a and b c', tuple('a and b ', 9))
asserteq(me'a+b', tuple('a+b', 4))
asserteq(me'a+b b=c', tuple('a+b ', 5))
asserteq(me'{function()end}+b c', tuple('{function()end}+b ', 19))
asserteq(me'{} e', tuple('{} ', 4))
asserteq(me'() e', tuple('() ', 4))
asserteq(me'"" e', tuple('"" ', 4))
asserteq(me"'' e", tuple("'' ", 4))
asserteq(me'a[1] e', tuple('a[1] ', 6))
asserteq(me'ab.cd e', tuple('ab.cd ', 7))
asserteq(me'ab:cd() e', tuple('ab:cd() ', 9))
asserteq(me'(x) (y) z', tuple('(x) (y) ', 9))
asserteq(me'x >= y', tuple('x >= y', 7))

-- numbers
asserteq(me'1e2 a', tuple('1e2 ', 5))
asserteq(me'1e+2 a', tuple('1e+2 ', 6))
asserteq(me'1.2e+2 a', tuple('1.2e+2 ', 8))
asserteq(me'.2e+2 a', tuple('.2e+2 ', 7))

-- comments
asserteq(me'a+ -- b\nc', tuple('a+ -- b\nc', 10))
asserteq(me'a --[[]] b', tuple('a --[[]] ', 10))
asserteq(me'a+ --[[]] b', tuple('a+ --[[]] b', 12))
asserteq(me'a --[[]] + b', tuple('a --[[]] + b', 13))
asserteq(me'a+ --[[]] --[=[]=] b', tuple('a+ --[[]] --[=[]=] b', 21))
asserteq(me'a+ -- b\n -- b\n b c', tuple('a+ -- b\n -- b\n b ', 18))

-- check for exceptions giving lots of possibly not syntactically
-- correct data.
local text = io.open'tests/tests.lua':read'*a'
for i=1,#text do
  local res = me(text,i)
  if res[1] == 'error' and not res[2]:match('syntax error') then
    error(res[2])
  end
end

--## match_explist tests

local ml = function(...)
  local res = wrap2(lb.match_explist)(...)
  res[1] = table.concat(res[1], '|')
  return res
end
asserteq(ml ' d', tuple(' ', 2))
asserteq(ml 'a+b,b*c d', tuple('a+b|b*c ', 9))

--## match_namelist tests

local ml = function(...)
  local res = wrap2(lb.match_namelist)(...)
  res[1] = table.concat(res[1], '|')
  return res
end
asserteq(ml ' ', tuple('', 1))
asserteq(ml 'a b', tuple('a', 3))
asserteq(ml 'a,b d', tuple('a|b', 5))
asserteq(ml 'a,b+d', tuple('a|b', 4))


--## gsub tests

local ls = lb.gsub

local function f(u, s)
  return '[' .. u .. ':' .. s .. ']'
end

asserteq(ls('', f), '')
asserteq(ls(' ', f), '[e: ]')
asserteq(ls(' "z" ;', f), '[e: ][s:"z"][e: ;]')
asserteq(ls(' --[[z]] ;', f), '[e: ][c:--[[z]]][e: ;]')
asserteq(ls(' --z\n ;', f), '[e: ][c:--z\n][e: ;]')
asserteq(ls(' --z', f), '[e: ][c:--z]')
asserteq(ls('[][=[ ] ]=] ;', f), '[e:[]][s:[=[ ] ]=]][e: ;]')
asserteq(ls('a - b --[[d]] .. "--"', f), '[e:a - b ][c:--[[d]]][e: .. ][s:"--"]')

print 'DONE'

