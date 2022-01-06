local eclipse = require "nvim-lsp-installer.core.clients.eclipse"
local CheckResult = require "nvim-lsp-installer.jobs.outdated-servers.check-result"

---@param server Server
---@param source InstallReceiptSource
---@param on_check_result fun(result: CheckResult)
return function(server, source, on_check_result)
    eclipse.fetch_latest_jdtls_version(function(err, latest_version)
        if err then
            return on_check_result(CheckResult.fail(server))
        end
        if source.version ~= latest_version then
            return on_check_result(CheckResult.success(server, {
                {
                    name = "jdtls",
                    current_version = source.version,
                    latest_version = latest_version,
                },
            }))
        else
            return on_check_result(CheckResult.empty(server))
        end
    end)
end
