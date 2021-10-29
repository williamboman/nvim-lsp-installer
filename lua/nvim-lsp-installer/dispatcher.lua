local notify = require "nvim-lsp-installer.notify"
local log = require "nvim-lsp-installer.log"

local M = {}

local registered_callbacks = {}

M.dispatch_server_ready = function(server)
    for _, callback in pairs(registered_callbacks) do
        local ok, err = pcall(callback, server)
        log.fmt_debug("running on_server_ready for [%s]", server.name)
        if not ok then
            notify(tostring(err), vim.log.levels.ERROR)
        end
    end
end

local idx = 0
function M.register_server_ready_callback(callback)
    local key = idx + 1
    registered_callbacks[("%d"):format(key)] = callback
    return function()
        table.remove(registered_callbacks, key)
    end
end

return M
