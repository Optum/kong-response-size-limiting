local BasePlugin = require "kong.plugins.base_plugin"
local tonumber = tonumber
local MB = 2^20

local responsestr = "{\"message:\" \"Response size limit exceeded\"}"

local KongResponseSizeLimitingHandler = BasePlugin:extend()
KongResponseSizeLimitingHandler.PRIORITY = 802

function KongResponseSizeLimitingHandler:new()
	KongResponseSizeLimitingHandler.super.new(self, "kong-response-size-limiting")
end

local function check_size(length, allowed_size)
  local allowed_bytes_size = allowed_size * MB
  if length > allowed_bytes_size then
      ngx.ctx.responsetoolarge = true
  end
end

function KongResponseSizeLimitingHandler:header_filter(conf)
  KongResponseSizeLimitingHandler.super.header_filter(self)
  local cl = kong.service.response.get_header("content-length")
  if cl and tonumber(cl) then
    check_size(tonumber(cl), conf.allowed_payload_size)
  else
    ngx.log(ngx.DEBUG, "Upstream response lacks Content-Length header!")
  end
end

function KongResponseSizeLimitingHandler:body_filter(conf)
  KongResponseSizeLimitingHandler.super.body_filter(self)
  if ngx.ctx.responsetoolarge then
    kong.response.set_status(413)
    kong.response.set_header("Content-Length", #responsestr)
    kong.response.set_header("Content-Type", "application/json")		
    ngx.arg[1] = responsestr
    ngx.arg[2] = true
  end
end

return KongResponseSizeLimitingHandler
