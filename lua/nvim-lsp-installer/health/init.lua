local health = require "health"
local process = require "nvim-lsp-installer.process"
local platform = require "nvim-lsp-installer.platform"
local Data = require "nvim-lsp-installer.data"

local when = Data.when

local gem_cmd = platform.is_win and "gem.cmd" or "gem"
local composer_cmd = platform.is_win and "composer.bat" or "composer"
local npm_cmd = platform.is_win and "npm.cmd" or "npm"

local M = {}

---@alias HealthCheckResult
---| '"success"'
---| '"version-mismatch"'
---| '"parse-error"'
---| '"not-available"'

---@class HealthCheck
---@field public result HealthCheckResult
---@field public version string|nil
---@field public relaxed boolean|nil
---@field public reason string|nil
---@field public name string
local HealthCheck = {}
HealthCheck.__index = HealthCheck

function HealthCheck.new(props)
    local self = setmetatable(props, HealthCheck)
    return self
end

function HealthCheck:get_version()
    if self.result == "success" and not self.version or self.version == "" then
        -- Some checks (bourne shell for instance) don't produce any output, so we default to just "Ok"
        return "Ok"
    end
    return self.version
end

function HealthCheck:get_health_report_level()
    return ({
        ["success"] = "report_ok",
        ["parse-error"] = "report_warn",
        ["version-mismatch"] = "report_error",
        ["not-available"] = self.relaxed and "report_warn" or "report_error",
    })[self.result]
end

function HealthCheck:__tostring()
    if self.result == "success" then
        return ("**%s**: `%s`"):format(self.name, self:get_version())
    elseif self.result == "version-mismatch" then
        return ("**%s**: unsupported version `%s`. %s"):format(self.name, self:get_version(), self.reason)
    elseif self.result == "parse-error" then
        return ("**%s**: failed to parse version"):format(self.name)
    elseif self.result == "not-available" then
        return ("**%s**: not available"):format(self.name)
    end
end

---@param callback fun(result: HealthCheck)
local function mk_healthcheck(callback)
    ---@param opts {cmd:string, args:string[], name: string, use_stderr:boolean}
    return function(opts)
        return function()
            local stdio = process.in_memory_sink()
            local _, stdio_pipes = process.spawn(opts.cmd, {
                args = opts.args,
                stdio_sink = stdio.sink,
            }, function(success)
                if success then
                    local version = vim.split(
                        table.concat(opts.use_stderr and stdio.buffers.stderr or stdio.buffers.stdout, ""),
                        "\n"
                    )[1]

                    if opts.version_check then
                        local ok, version_check = pcall(opts.version_check, version)
                        if ok and version_check then
                            callback(HealthCheck.new {
                                result = "version-mismatch",
                                reason = version_check,
                                version = version,
                                name = opts.name,
                                relaxed = opts.relaxed,
                            })
                            return
                        elseif not ok then
                            callback(HealthCheck.new {
                                result = "parse-error",
                                version = "N/A",
                                name = opts.name,
                                relaxed = opts.relaxed,
                            })
                            return
                        end
                    end

                    callback(HealthCheck.new {
                        result = "success",
                        version = version,
                        name = opts.name,
                        relaxed = opts.relaxed,
                    })
                else
                    callback(HealthCheck.new {
                        result = "not-available",
                        version = nil,
                        name = opts.name,
                        relaxed = opts.relaxed,
                    })
                end
            end)

            if stdio_pipes then
                -- Immediately close stdin to avoid leaving the process waiting for input.
                local stdin = stdio_pipes[1]
                stdin:close()
            end
        end
    end
end

function M.check()
    health.report_start "nvim-lsp-installer report"
    if vim.fn.has "nvim-0.7.0" == 1 then
        health.report_ok "neovim version >= 0.7.0"
    else
        health.report_error "neovim version < 0.7.0"
    end

    local completed = 0

    local check = mk_healthcheck(vim.schedule_wrap(
        ---@param healthcheck HealthCheck
        function(healthcheck)
            completed = completed + 1
            health[healthcheck:get_health_report_level()](tostring(healthcheck))
        end
    ))

    local checks = Data.list_not_nil(
        check {
            cmd = "go",
            args = { "version" },
            name = "Go",
            relaxed = true,
            version_check = function(version)
                -- Parses output such as "go version go1.17.3 darwin/arm64" into major, minor, patch components
                local _, _, major, minor = version:find "go(%d+)%.(%d+)"
                -- Due to https://go.dev/doc/go-get-install-deprecation
                if not (tonumber(major) >= 1 and tonumber(minor) >= 17) then
                    return "Go version must be >= 1.17."
                end
            end,
        },
        check { cmd = "cargo", args = { "--version" }, name = "cargo", relaxed = true },
        check { cmd = "ruby", args = { "--version" }, name = "Ruby", relaxed = true },
        check { cmd = gem_cmd, args = { "--version" }, name = "RubyGem", relaxed = true },
        check { cmd = composer_cmd, args = { "--version" }, name = "Composer", relaxed = true },
        check { cmd = "php", args = { "--version" }, name = "PHP", relaxed = true },
        check {
            cmd = npm_cmd,
            args = { "--version" },
            name = "npm",
            version_check = function(version)
                -- Parses output such as "8.1.2" into major, minor, patch components
                local _, _, major = version:find "(%d+)%.(%d+)%.(%d+)"
                -- Based off of general observations of feature parity
                if tonumber(major) < 6 then
                    return "npm version must be >= 6"
                end
            end,
        },
        check {
            cmd = "node",
            args = { "--version" },
            name = "node",
            version_check = function(version)
                -- Parses output such as "v16.3.1" into major, minor, patch
                local _, _, major = version:find "v(%d+)%.(%d+)%.(%d+)"
                if tonumber(major) < 14 then
                    return "Node version must be >= 14"
                end
            end,
        },
        when(
            platform.is_win,
            check { cmd = "python", use_stderr = true, args = { "--version" }, name = "python", relaxed = true }
        ),
        when(
            platform.is_win,
            check { cmd = "python", args = { "-m", "pip", "--version" }, name = "pip", relaxed = true }
        ),
        check { cmd = "python3", args = { "--version" }, name = "python3", relaxed = true },
        check { cmd = "python3", args = { "-m", "pip", "--version" }, name = "pip3", relaxed = true },
        check { cmd = "javac", args = { "-version" }, name = "javac", relaxed = true },
        check { cmd = "java", args = { "-version" }, name = "java", relaxed = true },
        check { cmd = "julia", args = { "--version" }, name = "julia", relaxed = true },
        check { cmd = "wget", args = { "--version" }, name = "wget" },
        -- wget is used interchangeably with curl, but with higher priority, so we mark curl as relaxed
        check { cmd = "curl", args = { "--version" }, name = "curl", relaxed = true },
        check {
            cmd = "gzip",
            args = { "--version" },
            name = "gzip",
            use_stderr = platform.is_mac, -- Apple gzip prints version string to stderr
        },
        check { cmd = "tar", args = { "--version" }, name = "tar" },
        when(
            vim.g.python3_host_prog,
            check { cmd = vim.g.python3_host_prog, args = { "--version" }, name = "python3_host_prog", relaxed = true }
        ),
        when(platform.is_unix, check { cmd = "bash", args = { "--version" }, name = "bash" }),
        when(platform.is_unix, check { cmd = "sh", name = "sh" })
        -- when(platform.is_win, check { cmd = "powershell.exe", args = { "-Version" }, name = "PowerShell" }), -- TODO fix me
        -- when(platform.is_win, check { cmd = "cmd.exe", args = { "-Version" }, name = "cmd" }) -- TODO fix me
    )

    for _, c in ipairs(checks) do
        c()
    end

    vim.wait(5000, function()
        return completed >= #checks
    end, 50)
end

return M
