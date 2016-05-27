local cjson = require "cjson.safe"
local function var_dump1(tb)
    for k,v in pairs(tb) do
        if ngx then
            ngx.say( k..k)
        else
            print(k,v)
        end
    end
end

local function var_dump(val)
    level = level or 0
    local space = 1
    if type(val) == 'table' then
        for i, j in pairs(val) do
            ngx.say(string.rep('\t', space*level) .. i .. ' = {')
            var_dump(j, level + 1)
            ngx.say(string.rep('\t', space*level) .. '}')
        end
    else
        ngx.say(string.rep('\t', space*level) .. tostring(val))
    end
end


local function explode(szFullString, szSeparator)

    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray

end

function http_build_query(data, prefix, sep, _key)
    local ret = {}
    local prefix = prefix or ''
    local sep = sep or '&'
    local _key = _key or ''

    for k,v in pairs(data) do
        if (type(k) == "number" and prefix ~= '') then
            k = ngx.escape_uri(prefix .. k)
        end
        if (_key ~= '' or _key == 0) then
            k = ngx.escape_uri(("%s[%s]"):format(_key, k))
        end
        if (type(v) == 'table') then
            table.insert(ret, http_build_query(v, '', sep, k))
        else
            table.insert(ret, ("%s=%s"):format(k, ngx.escape_uri(v)))
        end
    end
    return table.concat(ret, sep)
end

local function parse_str(str)
    local tb = {}
    local pos = 1
    local s = string.find(str,"&",pos)
    while true do
        local kv = string.sub(str,1,s-1)
        local k,v = string.match(kv,"([^=]*)=([^=]*)")
        tb[k] = v
        pos   = s + 1
        str   = string.sub(str,pos)
        s     = string.find(str,"&",1)
        if s == nil then
            k,v = string.match(str,"([^=]*)=([^=]*)")
            tb[k] = v
            break
        end
    end
    return tb
end
local function Trim(str)
    if type(str) ~= 'string' then
        return ''
    end
    local s = string.gsub(str, "^%s*(.-)%s*$", "%1")
    return s
end

local function rawurldecode(s)
     s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
     return s
end
local function compare(str1,str2)

    len1  = string.len(str1)
    len2  = string.len(str2)
    ngx.say(len1 == len2 )
    for i = 1 , len1 do
        char1 = string.sub(str1,i,i)
        char2 = string.sub(str2,i,i)
        ngx.say( char1 == char2 )
        ngx.say(char1, char2)
    end
end

local function getClientIp()
    
    IP = ngx.req.get_headers()["X-Real-IP"]
    if IP == nil then
        IP  = ngx.var.remote_addr 
    end
    if IP == nil then
        IP  = "unknown"
    end
    return IP
end

local function loadEnv()

    local f = assert(io.open(ngx.var.lua_env_path, "r"))
    local env = {}

    for line in io.lines(ngx.var.lua_env_path) do
        local l = require(ngx.var.lua_lib_root .. '/common').explode(line, '=')
        if l[1] ~= '_' and l[1] ~= 'SHELL' and ngx.re.match(l[1], '^[0-9A-Z_-]+$') then
            env[l[1]] = l[2]
        end
    end

    return env
end
local function makeJson(data,errno,errmsg,callback)
    local allres  = {}
    allres['errno'] = errno
    allres['message'] = errmsg
    allres['data'] = data
    
    local res  = cjson.encode(allres)
    if not require('lib/tools').emptyStr(callback)  then
        res = require('lib/tools').htmlspecialchars(callback).."("..res..");"
    end
    return res
end
local function empty(var)
    if type(var) == 'table' then
        return next(var) == nil
    end
    return var == nil or var == '' or  not var 
end
local function emptyStr(var)
    return var == nil or var == '' or tostring(var) == 'nil'  or  not var
end
local function emptyNum(var)
    return var == nil or var == '' or tonumber(var) <= 0 or tonumber(var) == nil or  not var
end
local function trim(str)
    if type(str) ~= 'string' then
        return ''
    end
    local s = string.gsub(str, "^%s*(.-)%s*$", "%1")
    return s
end
local function mergeTable(t1,t2)
    local new_table  = {}
    for i ,v in ipairs(t1) do 
        table.insert(new_table,v)
    end
    for i ,v in ipairs(t2) do 
        table.insert(new_table,v)
    end
end
local function getIDC()
        local t = io.popen('uname -a | awk -F"." \'{print $3}\'')
        local out = require("lib/tools").trim(t:read("*all")) or ''

        local idc_list = {'bjdt', 'zzbc', 'zzzc', 'shjc', 'shm', 'gzst'}

        for _, idc in pairs(idc_list) do
                if out == idc then
                        return out
                end
        end
        return 'default'
end
local function htmlspecialchars(str)
    local str, n, err = ngx.re.gsub(str, "&", "&amp;")
    str, n, err = ngx.re.gsub(str, "<", "&lt;")
    str, n, err = ngx.re.gsub(str, ">", "&gt;")
    str, n, err = ngx.re.gsub(str, '"', "&quot;")
    str, n, err = ngx.re.gsub(str, "'", "&apos;")
    return str
end
local function Split(szFullString, szSeparator)

    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray

end
local function explode(delimiter, str, ...)
    if delimiter == '' then
        return str
    end
    local pos,arr = 0,{}
    local limit = ...
    local num = 0
    for st,sp in function() return string.find(str,delimiter,pos,true) end do
        table.insert(arr,string.sub(str,pos,sp-1))
        pos = sp + 1
        num = num + 1
        if limit and num == limit then
            break
        end
    end
    table.insert(arr,string.sub(str,pos))
    return arr
end
function readJsonFile(path)
    local fp = io.open(path, "rb") 
    local template = fp:read('*a')
    fp:close()
    return cjson.decode(template)
end
function writefile(path,data)
    local fp = io.open(path, "w") 
    local template = fp:write(data)
    fp:close()
    return template
end
local function http_build_query_sort(data, prefix, sep, _key)
    local ret = {}
    local prefix = prefix or ''
    local sep = sep or '&'
    local _key = _key or ''

    local keyt  = {}
    for k,_ in pairs(data) do
        table.insert(keyt,k)
    end
    table.sort(keyt)
    local sort_table  = {}
    for _,key in ipairs(keyt) do
        local k  = key
        local v = data[k]
        if (type(k) == "number" and prefix ~= '') then
            k = prefix .. k
        end
        if (_key ~= '' or _key == 0) then
            k = ("%s[%s]"):format(_key, k)
        end
        if (type(v) == 'table') then
            table.insert(ret, _http_build_query(v, '', sep, k))
        else
            table.insert(ret, ("%s=%s"):format(k, tostring(v)))
        end
    end
    return table.concat(ret, sep)
end
function clearHTML(html)
    html = string.gsub(html, '<script[%a%A]->[%a%A]-</script>', '')
    html = string.gsub(html, '<style[%a%A]->[%a%A]-</style>', '')
    html = string.gsub(html, '<[%a%A]->', '')
    html = string.gsub(html, '\n\r', '\n')
    html = string.gsub(html, '%s+\n', '\n')
    html = string.gsub(html, '\n+', '\n')
    html = string.gsub(html, '\n%s+', '\n')
    html = string.gsub(html, '^%s+', '')
    html = string.gsub(html, '%s+$', '')

    return html
end
local function _http_build_query(data, prefix, sep, _key)
    local ret = {}
    local prefix = prefix or ''
    local sep = sep or '&'
    local _key = _key or ''

    for k,v in pairs(data) do
        if (type(k) == "number" and prefix ~= '') then
            k = ngx.escape_uri(prefix .. k)
        end
        if (_key ~= '' or _key == 0) then
            k = ngx.escape_uri(("%s[%s]"):format(_key, k))
        end
        if (type(v) == 'table') then
            table.insert(ret, _http_build_query(v, '', sep, k))
        else
            table.insert(ret, ("%s=%s"):format(k, ngx.escape_uri(tostring(v))))
        end
    end
    return table.concat(ret, sep)
end
local function addslashes(str)
    --local str, n, err = ngx.re.gsub(str, "\\", '\\\\')
    local str, n, err = ngx.re.gsub(str, '"', '\\"')
    str, n, err = ngx.re.gsub(str, "'", "\\'")
    return str
end
local function utfstrlen(str)
    local len = #str;
    local left = len;
    local cnt = 0;
    local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc};
    while left ~= 0 do
        local tmp=string.byte(str,-left);
        local i=#arr;
        while arr[i] do
            if tmp>=arr[i] then left=left-i;break;end
            i=i-1;
        end
        cnt=cnt+1;
    end
    return cnt;
end
local function replace()
  ngx.re.gsub(html, "http:\\/\\/xxxxxxx\\d{1,2}\\.vvvvvvvv\\.com\\/", 'http://xx.vv.com/')
end

