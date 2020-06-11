local tonumber = tonumber
local MB = 2^20
local responsestr = "{\"message\": \"Response size limit exceeded\"}"

local KongResponseSizeLimitingHandler = {}
KongResponseSizeLimitingHandler.PRIORITY = 802
KongResponseSizeLimitingHandler.VERSION = "2.0.0"

local function check_size(length, allowed_size)
  local allowed_bytes_size = allowed_size * MB
  if length > allowed_bytes_size then
      ngx.ctx.responsesizelimiter = true
      ngx.status = 413
      ngx.header["Content-Length"] = #responsestr
      ngx.header["Content-Type"] = "application/json"
  end
end

function KongResponseSizeLimitingHandler:header_filter(conf)
  local cl = ngx.var.upstream_http_content_length
  if cl and tonumber(cl) then
    check_size(tonumber(cl), conf.allowed_payload_size)
  else
    ngx.log(ngx.DEBUG, "Upstream response lacks Content-Length header!")
  end
end

function KongResponseSizeLimitingHandler:body_filter(conf)
  if ngx.ctx.responsesizelimiter then		
    ngx.arg[1] = responsestr
    ngx.arg[2] = true
  end
end

return KongResponseSizeLimitingHandler
