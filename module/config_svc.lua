local _M = {}
local cjson = require("cjson.safe")
local tools_lib = require('lib/tools')
local current_script_path = debug.getinfo(1, "S").source:sub(2)
local home_path = current_script_path:sub( 1, 0 - string.len("module/config_svc.lua") -1 ) 
framework_configpath  = home_path.."config/"
local all_config  = tools_lib.readJsonFile(framework_configpath.."all_config.json")

_M.dbcache_config  = all_config["dbcache_config"]


local config = ngx.shared.config_framework
--config:flush_all()
local function _setDbConfig()

    local idc = tools_lib.getIDC()
    config:set('dbcache_mysql', cjson.encode(_M.dbcache_config["MYSQL"]['database_default'][idc]))
    config:set('dbcache_wredis', cjson.encode(_M.dbcache_config["REDIS"]['cache_blog_wRedis'][idc]))
    config:set('dbcache_rredis', cjson.encode(_M.dbcache_config["REDIS"]['cache_blog_rRedis'][idc]))
    config:set('dbcache_memcached', cjson.encode(_M.dbcache_config["MEMCACHED"]['memcached_default'][idc]))
    return true

end
function _M:getDbConfig()
    local idc_dbcache_config  = {}
    idc_dbcache_config['mysql'] = cjson.decode(config:get('dbcache_mysql'))
    idc_dbcache_config['wredis'] = cjson.decode(config:get('dbcache_wredis'))
    idc_dbcache_config['rredis'] = cjson.decode(config:get('dbcache_rredis'))
    idc_dbcache_config['memcached'] = cjson.decode(config:get('dbcache_memcached'))

    return 0 ,idc_dbcache_config

end

function _M:init()

    if tools_lib.emptyStr(_M.dbcache_config)  then

        _getConfigByHttp()
        --local tcp = ngx.socket.tcp
        --local sock = tcp()
    end
    _setDbConfig()
end
function _M:update()

    if ngx.worker.id() > 0 then
        _timer()
        _setDbConfig()

    end
    return
end


function _http_build_query(data, prefix, sep, _key)
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

function _timer()
    local delay = 3
    local check
    check = function(premature)
        if not premature then
            local ok, err = ngx.timer.at(delay, check)
            if not ok then
                ngx.log(ngx.ERR, "failed to create timerss: ", err)
                return
            end
        end
        _getConfigByHttp()
        ngx.log(ngx.ERR,"update config once")
    end
    local ok, err = ngx.timer.at(delay, check)
    if not ok then
        ngx.log(ngx.ERR, "failed to create timer: ", err)
        return
    end
end
function _getConfigByHttp()
    local params = {}
    local qs = _http_build_query(params)
    local http = require "resty.http"
    local hc = http:new()

    local ok, code, headers, status, body  = hc:request {
        url = "http://php.net/urlhowto.php",
        timeout = 3000,
        method = "GET", -- POST or GET
    }

    local args = cjson.decode(body) or {}
    if not tools_lib.emptyStr(args["dbcache_config"]) then

        _M.dbcache_config  = cjson.decode(args["dbcache_config"])
    end

end
function _M:new(o)
    o = o or {}
    setmetatable(o, { __index = _M })
    return o
end

return _M

