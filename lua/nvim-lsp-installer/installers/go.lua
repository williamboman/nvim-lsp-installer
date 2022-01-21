local std = require "nvim-lsp-installer.installers.std"
local installers = require "nvim-lsp-installer.installers"
local process = require "nvim-lsp-installer.process"

local M = {}

---@param package string The Go package to install.
function M.package(package)
    return installers.pipe {
        std.ensure_executables { { "go", "go was not found in path, refer to https://golang.org/doc/install." } },
        ---@type ServerInstallerFunction
        function(_, callback, ctx)
            local c = process.chain {
                env = process.graft_env {
                    GO111MODULE = "on",
                    GOBIN = ctx.install_dir,
                    GOPATH = ctx.install_dir,
                },
                cwd = ctx.install_dir,
                stdio_sink = ctx.stdio_sink,
            }

            ctx.receipt:with_primary_source(ctx.receipt.go(package))

            local pkg, version = unpack(vim.split(package, "@"))

            if ctx.requested_server_version then
                -- The "head" package is the recipient for the requested version. It's.. by design... don't ask.
                pkg = ("%s@%s"):format(pkg, ctx.requested_server_version)
              elseif version ~= nil then
                pkg = package
              else
                pkg = ("%s@latest"):format(pkg)
            end

            c.run("go", { "install", "-v", pkg })
            c.run("go", { "clean", "-modcache" })

            c.spawn(callback)
        end,
    }
end

function M.env(root_dir)
    return {
        PATH = process.extend_path { root_dir },
    }
end

return M
