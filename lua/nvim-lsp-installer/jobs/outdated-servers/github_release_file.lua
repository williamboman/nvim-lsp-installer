local github = require "nvim-lsp-installer.core.clients.github"
local CheckResult = require "nvim-lsp-installer.jobs.outdated-servers.check-result"

---@param server Server
---@param source InstallReceiptSource
---@param on_result fun(result: CheckResult)
return function(server, source, on_result)
    github.fetch_latest_release(
        source.repo,
        { tag_name_pattern = source.tag_name_pattern },
        function(err, latest_release)
            if err then
                return on_result(CheckResult.fail(server))
            end

            if source.release ~= latest_release.tag_name then
                return on_result(CheckResult.success(server, {
                    {
                        name = source.repo,
                        current_version = source.release,
                        latest_version = latest_release.tag_name,
                    },
                }))
            else
                return on_result(CheckResult.empty(server))
            end
        end
    )
end
