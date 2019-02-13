local commands = require("acid.commands")
local ops = commands.ops
local middlewares = require("acid.middlewares")

local features = {}

features.go_to = function(symbol, ns)
  return ops.info{symbol = symbol, ns = ns}:with_handler(middlewares.go_to(middlewares.nop))
end

features.list_usage = function(callback, symbol, ns, pwd, fname)

  local handle = function(data)
    return ops['find-symbol']{
        path = pwd,
        file = fname,
        ns = data.ns,
        name = data.name,
        line = math.floor(data.line or 1),
        column = math.floor(data.column or 1),
        ['serialization-format'] = 'bencode'
      }:with_handler(callback)
  end

  return ops.info{symbol = symbol, ns = ns}:with_handler(handle)
end

features.req = function(obj)

  local code = "(require '[" ..
    obj.ns ..
    (obj.alias ~= nil and (" :as" .. obj.alias) or "") ..
    "])"

  return ops.eval{code = code}:with_handler(
    middlewares.doautocmd{
      autocmd = "AcidRequired",
      handler = (obj.handler or middlewares.nop_handler)
  })
end

-- TODO add config layer
-- So handlers could be selected by default
features.eval = function(obj)
  return ops.eval{code = obj.code}:with_handler(obj.handler)
end

return features