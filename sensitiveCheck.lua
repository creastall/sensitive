require("helper")
sensitiveWordTable=
{
"强奸",
"强奸妇女",
"杀人",
"杀人放火"
}
--把字符串转换为table，table里面是单个字符，可以识别中文
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
local function checkadd(dict,key,isend)
   local tmp = dict["" .. key]
   if tmp == nil then
      tmp = {}
      dict["" .. key] = tmp
   end
   if isend then
      tmp["ee"] = 1
   end
   return tmp
end
local function checkexist(dict,key)
   local tmp = dict["" .. key]
   if tmp == nil then
      return dict
   end
   return tmp
end
ALLBadStringDict = {}
AllSepStringDict = {}

local AllSepString={"*","+","-","."," ","=","\'","\"",";",":"}
--创建字典索引
local function initBadString()
    for k,v in pairs(sensitiveWordTable) do
        local word = strToTable(v)
        local nextdict = ALLBadStringDict
        for i,key in pairs(word) do
            nextdict = checkadd(nextdict,key,i == #word)
        end
    end
    for k,v in pairs(AllSepString) do
        local tmp = AllSepStringDict[v]
        if tmp == nil then
           AllSepStringDict[v] = 1
        end
    end
end
function BadStringCheck(str,rep)
   local isinit = false
   for k,v in pairs(ALLBadStringDict) do
      isinit = true
      break
   end
   if not isinit then
      initBadString()
   end
   if str == nil or str == "" then
      return str
   end
   local strword = strToTable(str)
   local realword = {}
   local septable = {}
   for k,v in pairs(strword) do
      if AllSepStringDict[v] == nil then
         table.insert(realword,#realword+1,v)
      else
         local onesep = {}
         onesep.index = k
         onesep.sep = v
         table.insert(septable,#septable+1,onesep)
      end
   end
   local allindexarray = {}
   local nextdict = ALLBadStringDict
   local oneword = {}
   local tmpfound = {}
   local found = false
   local i = 1
   while i <= #realword do
      local key = realword[i]
      local before = nextdict
      nextdict = checkexist(nextdict,key)
      if nextdict == before then
         if #tmpfound > 0 then
            table.insert(allindexarray,#allindexarray+1,tmpfound)
            tmpfound={}
         end
         nextdict = ALLBadStringDict
         oneword = {}
         if found then
            i=i-1
            found = false
         end
      else
         found = true
         table.insert(oneword,#oneword+1,i)
         local en = nextdict["ee"]
         if en == 1 then
            if i == #realword then
                nextdict = ALLBadStringDict
                for _i,_v in pairs(oneword) do
                   table.insert(tmpfound,#tmpfound+1,_v)
                end
                table.insert(allindexarray,#allindexarray+1,tmpfound)
                tmpfound = {}
            else
                for _i,_v in pairs(oneword) do
                   table.insert(tmpfound,#tmpfound+1,_v)
                end
            end
            oneword = {}
         end
      end
      i=i+1
   end
   for i,v in pairs(allindexarray) do
      for ii,vv in pairs(v) do
         realword[vv] = rep or "*"
      end
   end
   for i,v in pairs(septable) do
      table.insert(realword,v.index,v.sep)
   end
   local ret = table.concat(realword)
   return {str~=ret,ret}
end
local word = "你好吗 ! 我要你了强奸"
--test-------
dump(BadStringCheck(word))
-- - "<var>" = {	
--     -     1 = true	--表示是否有敏感词汇
--     -     2 = "你好吗 ! 我要**你了"	
--     - }	

