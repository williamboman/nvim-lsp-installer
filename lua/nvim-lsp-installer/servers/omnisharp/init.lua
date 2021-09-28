local server = require "nvim-lsp-installer.server"
local platform = require "nvim-lsp-installer.platform"
local path = require "nvim-lsp-installer.path"
local Data = require "nvim-lsp-installer.data"
local std = require "nvim-lsp-installer.installers.std"
local context = require "nvim-lsp-installer.installers.context"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        installer = {
            context.github_release_file(
                "OmniSharp/omnisharp-roslyn",
                Data.coalesce(
                    Data.when(platform.is_mac, "omnisharp-osx.zip"),
                    Data.when(platform.is_linux and platform.arch == "x64", "omnisharp-linux-x64.zip"),
                    Data.when(
                        platform.is_win,
                        Data.coalesce(
                            Data.when(platform.arch == "x64", "omnisharp-win-x64.zip"),
                            Data.when(platform.arch == "arm64", "omnisharp-win-arm64.zip")
                        )
                    )
                )
            ),
            context.wrap(function(ctx)
                return std.unzip_remote(ctx.github_release_file, "omnisharp")
            end),
            std.chmod("+x", { "omnisharp/run" }),
        },
        default_options = {
            cmd = {
                platform.is_win and path.concat { root_dir, "OmniSharp.exe" } or path.concat {
                    root_dir,
                    "omnisharp",
                    "run",
                },
                "--languageserver",
                "--hostPID",
                tostring(vim.fn.getpid()),
            },
        },
    }
end
