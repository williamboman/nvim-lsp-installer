---@class CheckResult
---@field public server Server
---@field public success boolean
---@field public outdated_packages OutdatedPackage[]
local CheckResult = {}
CheckResult.__index = CheckResult

---@alias OutdatedPackage {name: string, current_version: string, latest_version: string}

---@param server Server
---@param outdated_packages OutdatedPackage[]
function CheckResult.new(server, success, outdated_packages)
    local self = setmetatable({}, CheckResult)
    self.server = server
    self.success = success
    self.outdated_packages = outdated_packages
    return self
end

---@param server Server
function CheckResult.fail(server)
    return CheckResult.new(server, false)
end

---@param server Server
---@param outdated_packages OutdatedPackage[]
function CheckResult.success(server, outdated_packages)
    return CheckResult.new(server, true, outdated_packages)
end

function CheckResult.empty(server)
    return CheckResult.success(server, {})
end

function CheckResult:has_outdated_packages()
    return #self.outdated_packages > 0
end

return CheckResult
