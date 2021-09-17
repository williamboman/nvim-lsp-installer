local path = require "nvim-lsp-installer.path"
local process = require "nvim-lsp-installer.process"
local installers = require "nvim-lsp-installer.installers"
local std = require "nvim-lsp-installer.installers.std"
local platform = require "nvim-lsp-installer.platform"

local M = {}

local gem = platform.is_win and "gem.cmd" or "gem"

function M.packages(packages)
    return installers.pipe {
        std.ensure_executables {
            { "ruby", "ruby was not found in path, refer to https://wiki.openstack.org/wiki/RubyGems." },
            { "gem", "gem was not found in path, refer to https://wiki.openstack.org/wiki/RubyGems." },
        },
        function(server, callback, context)
            process.spawn(gem, {
                args = {
                    "install",
                    "--no-user-install",
                    "--install-dir=.",
                    "--bindir=bin",
                    "--no-document",
                    table.concat(packages, " "),
                },
                cwd = server.root_dir,
                stdio_sink = context.stdio_sink,
            }, callback)
        end,
    }
end

function M.executable(root_dir, executable)
    return path.concat { root_dir, "bin", executable }
end

function M.env(root_dir)
    return {
        GEM_HOME = root_dir,
        GEM_PATH = root_dir,
    }
end

return M
