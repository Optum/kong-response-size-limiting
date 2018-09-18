package = "kong-response-size-limiting"
version = "0.1-0"
source = {
   url = "git+https://github.com/Optum/kong-response-size-limiting.git"
}
description = {
   summary = "This plugin will protect the client from consuming API responses that are deemed to large within the Kong API Gateway.",
   detailed = [[
   This plugin will protect the client from consuming API responses that are deemed to large within the Kong API Gateway.
   
   1. Plugin enables Kong users to specify the size in MB that they will allow for API response sizes.
   
   If transaction response is deemed to large the Gateway will throw an HTTP Status of 413 and a response body of "Response size limit exceeded"
   ]],
   homepage = "https://github.com/Optum/kong-response-size-limiting",
   license = "Apache 2.0"
}
dependencies = {}
build = {
   type = "builtin",
   modules = {
      ["kong.plugins.kong-spec-expose.handler"]  = "src/handler.lua",
      ["kong.plugins.kong-spec-expose.schema"]= "src/schema.lua"
   }
}
