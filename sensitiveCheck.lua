require("helper")
sensitiveWordTable=
{
"你好"
}

local function strToTable(str)
    local ret = {}
    local i = 1
    while i <= #str do
         local curByte = string.byte(str, i)
         local byteCount = 1;
         if curByte>0 and curByte<=127 then
             byteCount = 1
         elseif curByte>=192 and curByte<223 then
             byteCount = 2
         elseif curByte>=224 and curByte<239 then
             byteCount = 3
         elseif curByte>=240 and curByte<=247 then
             byteCount = 4
         end
         local char = string.sub(str, i, i+byteCount-1)
         table.insert(ret,#ret+1,char)
         i = i + byteCount
    end
    return ret
end
local word = "你好"
dump(strToTable(word))
dump(sensitiveWordTable,"sensitiveWordTable",10)


