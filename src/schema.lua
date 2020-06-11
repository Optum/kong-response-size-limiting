local typedefs = require "kong.db.schema.typedefs"

return {
  name = "kong-response-size-limiting",
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { allowed_payload_size = { type = "number", default = 128 }, },
  }
}
