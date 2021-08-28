local platform = require "nvim-lsp-installer.platform"

local M = {}

function M.compose(installers)
    if #installers == 0 then
        error "No installers to compose."
    end

    return function(server, callback)
        local function execute(idx)
            installers[idx](server, function(success, result)
                if not success then
                    -- oh no, error. exit early
                    callback(success, result)
                elseif installers[idx - 1] then
                    -- iterate
                    execute(idx - 1)
                else
                    -- we done
                    callback(success, result)
                end
            end)
        end

        execute(#installers)
    end
end

function M.inverse(installer, create_result)
    return function(server, callback)
        installer(server, function(success, _)
            callback(not success, create_result(not success, server))
        end)
    end
end

M.block_win = function(server, callback)
    if platform.is_win() then
        callback(false, ("Windows is not yet supported for server %q."):format(server.name))
    else
        callback(true, nil)
    end
end

M.block_unix = M.inverse(M.block_win, function(success, server)
    return success and nil or ("UNIX is not yet supported for server %q."):format(server.name)
end)

return M
