local redis, red = require "resty.redis", {}

function red:connect(host, port, pass)
    local red = redis:new()
    if not red then
        return false,"new err"
    end
    red:set_timeout(1000) -- 0.5 sec
    host = host or "127.0.0.1"
    port = port or 6379
    pass = pass or 123456
    local ok, err = red:connect(host, port)
    if not ok then
        return false, err
    end
    if pass then
        local res, err = red:auth(pass)
        if err then
            return false, err
        end
    end
    self.red = red
    return true, 'red ok'
end

function red:get(key)
    local red = self.red
    local res, err = red:get(key)
    return res, err
end

function red:set(key,v)
    local red = self.red
    local ok, err = red:set(key,v)
    if ok == 1 then
        return true, err
    end
    return false, err
end

function red:exists(key)
    local red = self.red
    local ok, err = red:exists(key)
    if ok == 1 then
        return true, 'exists'
    end
    return false, ok
end

function red:expire(key,n)
    local red = self.red
    local ok, err = red:expire(key,n)
    if not ok then
        return false, err
    end
    return true, ok
end

function red:incrby(key,n)
    local red = self.red
    local ok, err = red:incrby(key,n)
    if not ok then
        return 0, err
    end
    return ok, ok
end

function red:select(key)
    local red = self.red
    local res, err = red:select(key)
    if not res then
        return false, err
    end
    return true, res
end

function red:close()
    local red = self.red
    local ok, err = red:set_keepalive(10000, 100)
    if not ok then red:close() end
end

function red:new (o)  --注意，此处使用冒号，可以免写self关键字；
    o = o or {}  -- create object if user does not provide one
    setmetatable(o, {__index = self})
    return o
end

return red

