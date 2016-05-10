local _M = {}
local csjon = require("cjson.safe")
local tools_lib = require("lib/tools")
_M.attacklog  = false
local current_script_path = debug.getinfo(1, "S").source:sub(2)
local home_path = current_script_path:sub( 1, 0 - string.len("module/log_svc.lua") -1 ) 
_M.logpath  = home_path.."log/"

function write(logfile,msg)
    local fd = io.open(logfile,"ab")
    if fd == nil then return end
    fd:write(msg)
    fd:flush()
    fd:close()
end
function _writeLog(data)

    if _M.attacklog then
        if type(datas) == "table" then
            data = cjson.encode(data)
        else
            data  = tostring(data)
        end
        local line   =   tostring(ngx.var.remote_addr).." - "..tostring(ngx.var.remote_user).." ["..tostring(ngx.var.time_local).."] \""..tostring(ngx.var.request).."\" ".." \""..tostring(ngx.var.http_referer).."\" \""..tostring(ngx.var.http_user_agent).."\" \""..tostring(ngx.var.http_x_forwarded_for).."\" "..data.."\n";

        line = string.gsub(line,"nil","-")
        local filename = _M.logpath.."/"..ngx.today().."_framework.log"
        write(filename,line)
    end

end
function _M:log(data)
    _writeLog(data)
end
function _M:dot(begintime)
    if not tools_lib.emptyNum(begintime) then
        _writeLog(1000*ngx.now()-begintime)
        return
    else
        _writeLog(1000*ngx.now())
        return
    end 
end
function _M:init(attacklog,path)
    if attacklog then
        _M.attacklog =true
    end
    if not tools_lib.emptyStr(tostring(path)) then
        _M.logpath  = path
    end
end
function _M:new(o)
    o = o or {}
    setmetatable(o, { __index = _M })
    return o
end
return _M
