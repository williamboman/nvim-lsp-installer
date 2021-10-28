local server = require "nvim-lsp-installer.server"
local path = require "nvim-lsp-installer.path"
local Data = require "nvim-lsp-installer.data"
local std = require "nvim-lsp-installer.installers.std"
local platform = require "nvim-lsp-installer.platform"
local context = require "nvim-lsp-installer.installers.context"

local uv = vim.loop

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://clangd.llvm.org",
        installer = {
            context.use_github_release_file("clangd/clangd", function(version)
                return Data.coalesce(
                    Data.when(platform.is_mac, "clangd-mac-%s.zip"),
                    Data.when(platform.is_linux and platform.arch == "x64", "clangd-linux-%s.zip"),
                    Data.when(platform.is_win, "clangd-windows-%s.zip")
                ):format(version)
            end),
            context.capture(function(ctx)
                return std.unzip_remote(ctx.github_release_file)
            end),
            ---@type ServerInstallerFunction
            function(_, callback, ctx)
                local executable = path.concat {
                    ".",
                    ("clangd_%s"):format(ctx.requested_server_version),
                    "bin",
                    platform.is_win and "clangd.exe" or "clangd",
                }
                local filename = platform.is_win and "clangd.bat" or "clangd"
                local script = platform.is_win and ("@call %q %%*"):format(executable)
                    or table.concat({ "#/usr/bin/env sh", ("exec %q"):format(executable) }, "\n")

                uv.fs_open(path.concat { ctx.install_dir, filename }, "w", 438, function(open_err, fd)
                    if open_err then
                        ctx.stdio_sink.stderr(tostring(open_err) .. "\n")
                        return callback(false)
                    end
                    uv.fs_write(fd, script, -1, function(write_err)
                        if write_err then
                            ctx.stdio_sink.stderr(tostring(write_err) .. "\n")
                            callback(false)
                        else
                            ctx.stdio_sink.stdout(("Created %s\n"):format(filename))
                            callback(true)
                        end
                        assert(uv.fs_close(fd))
                    end)
                end)
            end,
            std.chmod("+x", { "clangd" }),
        },
        default_options = {
            cmd = { path.concat { root_dir, platform.is_win and "clangd.bat" or "clangd" } },
        },
    }
end
