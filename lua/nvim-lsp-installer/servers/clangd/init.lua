local server = require "nvim-lsp-installer.server"
local path = require "nvim-lsp-installer.path"
local Data = require "nvim-lsp-installer.data"
local std = require "nvim-lsp-installer.installers.std"
local platform = require "nvim-lsp-installer.platform"
local context = require "nvim-lsp-installer.installers.context"
local installers = require "nvim-lsp-installer.installers"

local uv = vim.loop

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        installer = {
            context.github_release_file("clangd/clangd", function(version)
                return Data.coalesce(
                    Data.when(platform.is_mac, "clangd-mac-%s.zip"),
                    Data.when(platform.is_linux, "clangd-linux-%s.zip"),
                    Data.when(platform.is_win, "clangd-windows-%s.zip")
                ):format(version)
            end),
            context.capture(function(ctx)
                return std.unzip_remote(ctx.github_release_file)
            end),
            installers.when {
                unix = function(server, callback, context)
                    local path = path.concat {
                        server.root_dir,
                        ("clangd_%s"):format(context.requested_server_version),
                        "bin",
                        "clangd",
                    }
                    local new_path = path.concat { server.root_dir, "clangd" }
                    context.stdio_sink.stdout(("Creating symlink from %s to %s"):format(path, new_path))
                    uv.fs_symlink(
                        path,
                        new_path,
                        function(err, success)
                            if not success then
                                context.stdio_sink.stderr(tostring(err))
                                callback(false)
                            else
                                callback(true)
                            end
                        end
                        )
                    print(vim.inspect(test))
                end,
                win = function (server,callback,context)
                    context.stdio_sink.stdout("Creating clangd.bat...")
                    uv.fs_open(path.concat { server.root_dir, "clangd.bat" }, "w", 438, function (err, fd)
                        local path = path.concat {
                            server.root_dir,
                            ("clangd_%s"):format(context.requested_server_version),
                            "bin",
                            "clangd.exe",
                        }
                        if err then
                            context.stdio_sink.stderr(tostring(err))
                            return callback(false)
                        end
                        uv.fs_write(fd, ("@call %q %%*"):format(path), -1, function (err)
                            if err then
                                context.stdio_sink.stderr(tostring(err))
                                callback(false)
                            else
                                context.stdio_sink.stdout("Created clangd.bat")
                                callback(true)
                            end
                            assert(uv.fs_close(fd))
                        end)
                    end)
                end
            },
        },
        default_options = {
            cmd = { path.concat { root_dir, platform.is_win and "clangd.bat" or "clangd" } },
        },
    }
end
