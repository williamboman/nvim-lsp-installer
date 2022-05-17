local fun = require "nvim-lsp-installer.core.functional.function"
local rel = require "nvim-lsp-installer.core.functional.relation"

local _ = {}

_.is_nil = rel.equals(nil)

---@param typ type
---@param value any
_.is = fun.curryN(function(typ, value)
    return type(value) == typ
end, 2)

return _
