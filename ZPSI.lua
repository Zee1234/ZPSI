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
ZPSI = {}
OUTPUT = {}

function StringFunctions(inputstring,method,e1,e2,e3,e4)
  local switch = {
    ["DashString"] = function(value) return string.match(value,"%-*") end,
    ["FirstColon"] = function(value) return tonumber(string.match(string.find(value,"[^\\]:"),"%d*"))+1 end,
    ["ValueText"] = function(value,position) return string.sub(value,position+2) end,
    ["CheckIfNum"] = function(value) if string.match(value:match(".*%S"),"^%-?%d*%.?%d*$") then return true else return false end end,
    ["CheckIfBool"] = function(value)
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
    end, 
  }
  return switch[method](inputstring,e1,e2,e3,e4)
end

function DepthArrayToFields(fieldarray,depth)
  if (depth==0) then return "" end
  return DepthArrayToFields(fieldarray,depth - 1) .. "." .. tostring(fieldarray[depth])
end

function SetField (fields,value,a_Array,arraynum)
  local t = OUTPUT
  for w, d in string.gmatch(fields, "([%w_]+)(.?)") do
    if d == "." then
      t[w] = t[w] or {}
      t = t[w]
    else
      if a_Array then
        t[arraynum] = value
      else
        t[w] = value
      end
    end
  end
end

function Check_Type(input)
  if(type(input) ~= "table") then return type(input) end
  local i = 1
  for _ in pairs(input) do
    if input[i] ~= nil then i = i + 1 else return "table" end
  end
  if i == 1 then return "table" else return "array" end
end

function FindType(a_String,truncate)
  local isNum, isBool, BoolVal = StringFunctions(a_String,"CheckIfNum"),StringFunctions(a_String,"CheckIfBool")
  if isNum then return tonumber(string.match(a_String,".*%S")) end
  if isBool then return BoolVal end
  return if truncate then string.match(a_String,".*%S") else a_String end
end

function CheckValueOrObj(a_String,truncate)
  if(not a_String:match("%g")) then
    return {}
  else
    if truncate then
      return FindType(a_String,true)
    else
      return FindType(a_String,false)
    end
  end
end

function ZPSI.parse(filename,truncate)
  if not truncate then truncate = true end
  local DEPTHNAMES = {}
  local file = io.open(filename)
  local linenum = 1
  local lastarrayline = 0
  local arraynum = 1
  for lines in file:lines() do
    if string.match(lines,"^%S.*") and (string.sub(string.match(lines,"^%S.*"),1,1) ~= "#") then
      local dashes = StringFunctions(lines,"DashString")
      local depthnum = string.len(dashes)
      local firstcolon = StringFunctions(lines,"FirstColon")
      local value = StringFunctions(lines,"ValueText",firstcolon)
      if(depthnum ~= (firstcolon - 1)) then
        DEPTHNAMES[depthnum + 1] = string.sub(lines,depthnum+1,firstcolon-1)
        SetField(DepthArrayToFields(DEPTHNAMES,depthnum+1),CheckValueOrObj(value,truncate),false)
      else
        if linenum ~= lastarrayline + 1 then arraynum = 1 end
        DEPTHNAMES[depthnum + 1] = arraynum
        SetField(DepthArrayToFields(DEPTHNAMES,depthnum+1),CheckValueOrObj(value,truncate),true,arraynum)
        lastarrayline = linenum
        arraynum = arraynum+1
      end
      linenum = linenum + 1
    end
  end
  return OUTPUT
end

function ZPSI.truncate(a_String)
  return string.match(a_String,".*%S")
end
