local fetch = require "nvim-lsp-installer.core.fetch"
local M = {}

---@alias Crate {crate: {id: string, max_stable_version: string, max_version: string, newest_version: string}}

---@param crate string
---@param callback fun(err: string|nil, data: Crate|nil)
function M.fetch_crate(crate, callback)
    fetch(("https://crates.io/api/v1/crates/%s"):format(crate), function(err, data)
        if err then
            callback(err, nil)
            return
        end
        callback(nil, vim.json.decode(data))
    end)
end

return M
