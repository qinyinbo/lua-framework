local _M = {}
local cjson = require("cjson.safe")
local config = ngx.shared.config_qgate
local log_svc  = require("module/log_svc"):new()
_M.log = log_svc

function _M:login()
    
    local http = require "resty.http"
    local cookie  = require('resty.cookie'):new()
    local Qgate_cookie = cookie:get('Qgate')
    if Qgate_cookie  then
        local cookie_value =require("lib/tools").Split(Qgate_cookie,'_')
        if cookie_value[1] == ngx.md5(cookie_value[2].."framework") then
            cookie:set({
                key = "framework",
                value = Qgate_cookie,
                path = "/",
                max_age = 1,
            })
            return true
        else
            _M.log:log(cookie_value)
            ngx.redirect("https://framework.com/login")
            ngx.exit(200)
        end
    else
        ngx.redirect("https://framework.com/login")
        ngx.exit(200)
    end
end

function _M:new(o)
    o = o or {}
    setmetatable(o, { __index =self })
    return o
end
return _M
