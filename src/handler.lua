local BasePlugin = require "kong.plugins.base_plugin"
local tonumber = tonumber
local MB = 2^20

local str = "Response size limit exceeded"

local KongResponseSizeLimitingHandler = BasePlugin:extend()
KongResponseSizeLimitingHandler.PRIORITY = 802

function KongResponseSizeLimitingHandler:new()
	KongResponseSizeLimitingHandler.super.new(self, "kong-response-size-limiting")
end

local function check_size(length, allowed_size)
  local allowed_bytes_size = allowed_size * MB
  if length > allowed_bytes_size then
      kong.ctx.plugin.limited = true
      kong.response.set_status(413)
      kong.response.set_header("Content-Length", #str)
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
  if kong.response.get_status() == 413 and kong.ctx.plugin.limited then
    ngx.arg[1] = str
    ngx.arg[2] = true  
  end
end

return KongResponseSizeLimitingHandler
