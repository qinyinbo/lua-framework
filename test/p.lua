local h = ngx.req.get_headers()
local args = ngx.req.get_uri_args()
         for key, val in pairs(args) do
             if type(val) == "table" then
                 ngx.say(key, ": ", table.concat(val, ", "))
             else
                 ngx.say(key, ": ", val)
             end
         end


local h = ngx.req.get_headers()
for k, v in pairs(h) do
     if type(v) == "table" then
         ngx.say(k, ": ", table.concat(v, ", "))
     else
         ngx.say(k, ": ", v)
     end
end


