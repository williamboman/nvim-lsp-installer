local installers = require "nvim-lsp-installer.installers"
local process = require "nvim-lsp-installer.process"

local M = {}

local function shell(opts)
    return function(server, callback, installer_opts)
        local _, stdio = process.spawn(opts.shell, {
            cwd = server.root_dir,
            stdio_sink = installer_opts.stdio_sink,
            env = process.graft_env(opts.env or {}),
        }, callback)

        local stdin = stdio[1]

        stdin:write(opts.cmd)
        stdin:write "\n"
        stdin:close()
    end
end

function M.bash(raw_script, opts)
    local default_opts = {
        prefix = "set -euo pipefail;",
        env = {},
    }
    opts = vim.tbl_deep_extend("force", default_opts, opts or {})

    return shell {
        shell = "/bin/bash",
        cmd = (opts.prefix or "") .. raw_script,
        env = opts.env,
    }
end

function M.remote_bash(url, opts)
    return M.bash(("wget -nv -O - %q | bash"):format(url), opts)
end

function M.cmd(raw_script, opts)
    local default_opts = {
        env = {},
    }
    opts = vim.tbl_deep_extend("force", default_opts, opts or {})

    return shell {
        shell = "cmd.exe",
        cmd = raw_script,
        env = opts.env,
    }
end

function M.polyshell(raw_script, opts)
    local default_opts = {
        env = {},
    }
    opts = vim.tbl_deep_extend("force", default_opts, opts or {})

    return installers.when {
        unix = M.bash(raw_script, { env = opts.env }),
        win = M.cmd(raw_script, { env = opts.env }),
    }
end

return M
