local std = require "nvim-lsp-installer.installers.std"
local installers = require "nvim-lsp-installer.installers"
local process = require "nvim-lsp-installer.process"

local M = {}

---@param packages string[] The OPAM packages to install. The first item in this list will be the recipient of the server version, should the user request a specific one.
function M.packages(packages)
    return installers.pipe {
        std.ensure_executables { { "opam", "opam was not found in path, refer to https://opam.ocaml.org/doc/1.1/Quick_Install.html." } },
        ---@type ServerInstallerFunction
        function(_, callback, ctx)
            local c = process.chain {
                cwd = ctx.install_dir,
                stdio_sink = ctx.stdio_sink,
            }

            -- Install the head package
            do
                local head_package = packages[1]
                ctx.receipt:with_primary_source(ctx.receipt.opam(head_package))
                c.run("opam", { "install", ("%s"):format(head_package) })
            end

            -- Install secondary packages
            for i = 2, #packages do
                local package = packages[i]
                ctx.receipt:with_secondary_source(ctx.receipt.opam(package))
                c.run("opam", { "install", "-v", ("%s"):format(package) })
            end

            c.spawn(callback)
        end
    }
end

function M.env(root_dir)
    return {
        PATH = process.extend_path { root_dir },
    }
end

return M
