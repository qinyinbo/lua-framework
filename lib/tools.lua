local cjson = require "cjson.safe"
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
    --删除空行
    html = string.gsub(html, '\n\r', '\n')
    html = string.gsub(html, '%s+\n', '\n')
    html = string.gsub(html, '\n+', '\n')
    html = string.gsub(html, '\n%s+', '\n')
    --删除前后空格
    html = string.gsub(html, '^%s+', '')
    html = string.gsub(html, '%s+$', '')

    return html
end
return {
    makeJson = makeJson,
    empty = empty,
    emptyNum = emptyNum,
    emptyStr = emptyStr,
    trim = trim,
    getIDC = getIDC,
    Split = Split,
    htmlspecialchars = htmlspecialchars,
    readJsonFile = readJsonFile,
    writefile = writefile,
    http_build_query_sort = http_build_query_sort,
    clearHTML = clearHTML,
}
