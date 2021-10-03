local Data = require "nvim-lsp-installer.data"
local log = require "nvim-lsp-installer.log"
local process = require "nvim-lsp-installer.process"
local platform = require "nvim-lsp-installer.platform"

local M = {}

local function fetch(url, callback)
    local stdio = process.in_memory_sink()
    if platform.is_unix then
        process.spawn("wget", {
            args = { "-nv", "-O", "-", url },
            stdio_sink = stdio.sink,
        }, function(success)
            if success then
                callback(nil, table.concat(stdio.buffers.stdout, ""))
            else
                callback(("Failed to fetch url=%s"):format(url), nil)
            end
        end)
    elseif platform.is_win then
        local script = {
            "$ProgressPreference = 'SilentlyContinue'",
            ("Write-Output (iwr -Uri %q).Content"):format(url),
        }
        process.spawn("powershell.exe", {
            args = { "-Command", table.concat(script, ";") },
            stdio_sink = stdio.sink,
        }, function(success)
            if success then
                callback(nil, table.concat(stdio.buffers.stdout, ""))
            else
                callback(("Failed to fetch url=%s"):format(url), nil)
            end
        end)
    else
        error "Unexpected error: Unsupported OS."
    end
end

function M.github_release_file(repo, file)
    return function(server, callback, context)
        local function get_download_url(version)
            local target_file = type(file) == "function" and file(version) or file
            if not target_file then
                context.stdio_sink.stderr(
                    (
                        "Could not find which release file to download. Most likely, the current operating system or architecture (%s) is not supported.\n"
                    ):format(platform.arch)
                )
                return nil
            end

            return ("https://github.com/%s/releases/download/%s/%s"):format(repo, version, target_file)
        end
        if context.requested_server_version then
            local download_url = get_download_url(context.requested_server_version)
            if not download_url then
                return callback(false)
            end
            context.github_release_file = download_url
            callback(true)
        else
            context.stdio_sink.stdout "Fetching latest release version from GitHub API...\n"
            fetch(
                ("https://api.github.com/repos/%s/releases/latest"):format(repo),
                vim.schedule_wrap(function(err, response)
                    if err then
                        context.stdio_sink.stderr "Failed to fetch latest release version from GitHub API.\n"
                        return callback(false)
                    end
                    local version = Data.json_decode(response).tag_name
                    log.debug("Resolved latest version", server.name, version)
                    context.requested_server_version = version
                    local download_url = get_download_url(version)
                    if not download_url then
                        return callback(false)
                    end
                    context.github_release_file = download_url
                    callback(true)
                end)
            )
        end
    end
end

function M.capture(fn)
    return function(server, callback, context, ...)
        local installer = fn(context)
        installer(server, callback, context, ...)
    end
end

function M.set(fn)
    return function(_, callback, context)
        fn(context)
        callback(true)
    end
end

return M
