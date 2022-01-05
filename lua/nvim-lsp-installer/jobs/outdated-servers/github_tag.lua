local github = require "nvim-lsp-installer.core.clients.github"
local CheckResult = require "nvim-lsp-installer.jobs.outdated-servers.check-result"

---@param server Server
---@param source InstallReceiptSource
---@param on_result fun(result: CheckResult)
return function(server, source, on_result)
    github.fetch_latest_tag(source.repo, function(err, latest_tag)
        if err then
            return on_result(CheckResult.fail(server))
        end

        if source.tag ~= latest_tag.name then
            return on_result(CheckResult.success(server, {
                {
                    name = source.repo,
                    current_version = source.tag,
                    latest_version = latest_tag.name,
                },
            }))
        else
            return on_result(CheckResult.empty(server))
        end
    end)
end
