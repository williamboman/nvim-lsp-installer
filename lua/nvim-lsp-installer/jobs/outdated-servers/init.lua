local JobExecutionPool = require "nvim-lsp-installer.jobs.pool"
local CheckResult = require "nvim-lsp-installer.jobs.outdated-servers.check-result"
local log = require "nvim-lsp-installer.log"

local npm_check = require "nvim-lsp-installer.jobs.outdated-servers.npm"
local pip3_check = require "nvim-lsp-installer.jobs.outdated-servers.pip3"
local gem_check = require "nvim-lsp-installer.jobs.outdated-servers.gem"
local git_check = require "nvim-lsp-installer.jobs.outdated-servers.git"
local github_release_file_check = require "nvim-lsp-installer.jobs.outdated-servers.github_release_file"
local github_tag_check = require "nvim-lsp-installer.jobs.outdated-servers.github_tag"

local M = {}

local jobpool = JobExecutionPool:new {
    size = 4,
}

local function noop(server, _, on_result)
    on_result(CheckResult.empty(server))
end

local checkers = {
    ["npm"] = npm_check,
    ["pip3"] = pip3_check,
    ["gem"] = gem_check,
    ["go"] = noop, -- TODO
    ["dotnet"] = noop, -- TODO
    ["unmanaged"] = noop,
    ["system"] = noop,
    ["jdtls"] = noop, -- TODO
    ["git"] = git_check,
    ["github_release_file"] = github_release_file_check,
    ["github_tag"] = github_tag_check,
}

---@param servers Server[]
---@param on_check_start fun(server: Server)
---@param on_result fun(result: CheckResult)
function M.identify_outdated_servers(servers, on_check_start, on_result)
    for _, server in ipairs(servers) do
        jobpool:supply(function(_done)
            local function complete(...)
                on_result(...)
                _done()
            end

            local receipt = server:get_receipt()
            if receipt then
                if
                    vim.tbl_contains({ "github_release_file", "github_tag" }, receipt.primary_source.type)
                    and receipt.schema_version == "1.0"
                then
                    -- Receipts of this version are in some cases incomplete.
                    return complete(CheckResult.fail(server))
                end

                local checker = checkers[receipt.primary_source.type]
                if checker then
                    on_check_start(server)
                    checker(server, receipt.primary_source, complete)
                else
                    complete(CheckResult.empty(server))
                    log.fmt_error("Unable to find checker for source=%s", receipt.primary_source.type)
                end
            else
                complete(CheckResult.empty(server))
                log.fmt_trace("No receipt found for server=%s", server.name)
            end
        end)
    end
end

return M
