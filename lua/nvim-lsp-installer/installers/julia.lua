local std = require "nvim-lsp-installer.installers.std"
local installers = require "nvim-lsp-installer.installers"
local Data = require "nvim-lsp-installer.data"
local process = require "nvim-lsp-installer.process"

local M = {}

---@param packages string[] @The Julia packages to install. The first item in this list will be the recipient of the server version, should the user request a specific one.
function M.packages(packages)
    return installers.pipe {
        std.ensure_executables {
            { "julia", "julia was not found in path, refer to https://julialang.org/downloads/." }
        },
        ---@type ServerInstallerFunction
        function(_, callback, ctx)
            local pkgs = Data.list_copy(packages or {})
            local c = process.chain {
                cwd = ctx.install_dir,
                stdio_sink = ctx.stdio_sink,
            }

            ctx.receipt:with_primary_source(ctx.receipt.julia(pkgs[1]))
            for i = 2, #pkgs do
                ctx.receipt:with_secondary_source(ctx.receipt.julia(pkgs[i]))
            end

            if ctx.requested_server_version then
                -- The "head" package is the recipient for the requested version.
                pkgs[1] = ("\\\"Pkg.PackageSpec(name=\\\"%s\\\", version=\\\"%s\\\")\\\""):format(pkgs[1], ctx.requested_server_version)
                for i = 2, #pkgs do
                    pkgs[i] = ("\\\"Pkg.PackageSpec(name=\\\"%s\\\")\\\""):format(pkgs[i])
                end
            else
                for i = 1, #pkgs do
                    pkgs[i] = "\\\""..pkgs[i].."\\\""
                end
            end

            local opt = "-e \"import Pkg; Pkg.add(["..table.concat(pkgs, ",").."])\""

            c.run("julia", { opt })

            c.spawn(callback)
        end,
    }
end

return M
