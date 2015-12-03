--[[
The MIT License

Copyright (c) 2015 Dimitri Futris https://github.com/Zee1234/ZPSI

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
--]]
local ZPSI = {}
local StringFunctions = {}
OUTPUT = {}

function StringFunctions.RemoveComments(a_string)
  a_string = a_string:gsub("^%s*(.*)","%1")
  if a_string:sub(1,1) == "#" then return "" end
  return a_string:gsub("^(.-)([^\\])#.*$","%1%2"):gsub("\\#","#")
end

function StringFunctions.FirstColon(a_string)
  local x,y = string.match(string.find(a_string,"[^\\]:"),"%d*")
  return y
end

function StringFunctions.GetType(a_string)
  local bool, boolval = StringFunctions.CheckIfBool(a_string)
  if bool then return boolval end
  local num, numval = StringFunctions.CheckIfNum(a_string)
  if num then return numval end
  return a_string
end

function StringFunctions.CheckIfNum(a_string)
  if string.match(a_string:match(".*%S"),"^%-?%d*%.?%d*$") then return true, tonumber(a_string) else return false end 
end

function StringFunctions.CheckIfBool(value)
  local a = string.match(value:lower(),"^true%s*$")
  local c = string.match(value:lower(),"^false%s*$")
  if a or c then
    if a then
      return true, true 
    else
      return true, false
    end
  else
    return false 
  end
end

function StringFunctions.GetDepth(a_string)
  local _,num = string.find(a_string,"^%-*.")
  return num - 1, string.sub(a_string,num)
end

function StringFunctions.GetKey(a_string)
  local colon = a_string:find(":") or 0
  if colon == 1 then return false, a_string:sub(2) end
  return string.match(a_string:sub(1,colon-1),"[%w_]+"), a_string:sub(colon+1)
end

function StringFunctions.GetMess(a_string,case)
  a_string = a_string:gsub("^%s*(.-)%s*$","%1")
  if a_string == "" then return {} end
  if a_string:find("^\".*\"$") then
    return ZPSI.replace(a_string:sub(2,a_string:len()-1),case)
  else
    return StringFunctions.GetType(ZPSI.replace(a_string,case))
  end
end

function StringFunctions.Deconstruct(a_string,case)
  local depth, key, message
  depth, a_string = StringFunctions.GetDepth(a_string)
  key, a_string = StringFunctions.GetKey(a_string)
  message = StringFunctions.GetMess(a_string,case)
  return depth,key,message
end

local SetValue = function(depth,store,value)
  local t = OUTPUT
  local w
  for i = 0, depth - 1 do
    w = store[i].name or store[i].lastarrelem + 1
    t[w] = t[w] or {}
    t = t[w]
  end
  w = store[depth].name or store[depth].lastarrelem + 1
  t[w] = value
end

--[[
{
  name = {string}/nil
  lastarrelem = {number}/nil
  subarrpres = nil/true
}
--]]

function ZPSI.parse(filename,case)
  local casetest = {[3]=true,[2]=true,[1]=true,[0]=true}
  if not case or not casetest[case] then case = 3 end
  local store = {}
  local file = io.open(filename)
  local linenum = 0
  local lastdepth = 0
  for lines in file:lines() do
    linenum = linenum + 1
    lines = StringFunctions.RemoveComments(lines)
    repeat
      if lines:len() == 0 or lines:match("%s*"):len() == lines:len() then break end
      local depth,key,message = StringFunctions.Deconstruct(lines,case)
      assert(depth <= lastdepth + 1, "Invalid key at line " .. tostring(linenum) .. "!")
      lastdepth = depth
      for i1 = #store, depth + 1, -1 do store[i1] = nil end
      store[depth] = store[depth] or {}
      if key then
        store[depth].name = key
      else
        store[depth].name = nil
        store[depth].lastarrelem = (store[depth].lastarrelem or -1) + 1
        store[depth].subelempres = nil
      end
      local prev = store[depth-1] or {}
      if prev.lastarrelem and not prev.subelempres then
        store[depth-1].subelempres = true
      end
      SetValue(depth,store,message)
    until true
  end
  return OUTPUT
end

function ZPSI.replace(a_string,case)
  local switch = {}
  switch[0] = function(b_string) return b_string end
  switch[1] = function(b_string) return b_string:gsub("([^\\])\\t","%1\t"):gsub("^\\t","\t"):gsub("\\\\t","\\t") end
  switch[2] = function(b_string) return b_string:gsub("([^\\])\\n","%1\n"):gsub("^\\n","\n"):gsub("\\\\n","\\n") end
  switch[3] = function(b_string) return b_string:gsub("([^\\])\\t","%1\t"):gsub("^\\t","\t"):gsub("\\\\t","\\t"):gsub("([^\\])\\n","%1\n"):gsub("^\\n","\n"):gsub("\\\\n","\\n") end
  return switch[case](a_string) or a_string
end

return ZPSI

