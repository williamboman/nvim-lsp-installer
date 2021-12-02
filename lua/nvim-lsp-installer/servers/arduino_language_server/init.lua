local path = require "nvim-lsp-installer.path"
local std = require "nvim-lsp-installer.installers.std"
local installers = require "nvim-lsp-installer.installers"
local server = require "nvim-lsp-installer.server"
local go = require "nvim-lsp-installer.installers.go"
local process = require "nvim-lsp-installer.process"
local platform = require "nvim-lsp-installer.platform"
local context = require "nvim-lsp-installer.installers.context"
local Data = require "nvim-lsp-installer.data"

local coalesce, when = Data.coalesce, Data.when

return function(name, root_dir)
    local arduino_cli_installer = installers.pipe {
        context.use_github_release_file("arduino/arduino-cli", function(version)
            local target_file = coalesce(
                when(platform.is_mac, coalesce(when(platform.arch == "x64", "arduino-cli_%s_macOS_64bit.tar.gz"))),
                when(
                    platform.is_linux,
                    coalesce(
                        when(platform.arch == "x64", "arduino-cli_%s_Linux_64bit.tar.gz"),
                        when(platform.arch == "x86", "arduino-cli_%s_Linux_32bit.tar.gz"),
                        when(platform.arch == "arm64", "arduino-cli_%s_Linux_ARM64.tar.gz"),
                        when(platform.arch == "armv6", "arduino-cli_%s_Linux_ARMv6.tar.gz"),
                        when(platform.arch == "armv7", "arduino-cli_%s_Linux_ARMv7.tar.gz")
                    )
                ),
                when(
                    platform.is_win,
                    coalesce(
                        when(platform.arch == "x64", "arduino-cli_%s_Windows_64bit.zip"),
                        when(platform.arch == "x86", "arduino-cli_%s_Windows_32bit.zip")
                    )
                )
            )
            return target_file and target_file:format(version)
        end),
        context.capture(function(ctx)
            if platform.is_win then
                return std.unzip_remote(ctx.github_release_file, "arduino-cli.exe")
            else
                return std.untargz_remote(ctx.github_release_file)
            end
        end),
        std.chmod("+x", { "arduino-cli" }),
    }

    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://github.com/arduino/arduino-language-server",
        languages = { "arduino" },
        installer = {
            arduino_cli_installer,
            ---@type ServerInstallerFunction
            function(_, callback, ctx)
                process.spawn(path.concat { root_dir, "arduino-cli" }, {
                    args = { "config", "init", "--dest-file", "arduino-cli.yaml", "--overwrite" },
                    cwd = ctx.install_dir,
                    stdio_sink = ctx.stdio_sink,
                }, callback)
            end,
            go.packages { "github.com/arduino/arduino-language-server" },
        },
        default_options = {
            cmd = {
                go.executable(root_dir, "arduino-language-server"),
                "-cli",
                path.concat { root_dir, platform.is_win and "arduino-cli.exe" or "arduino-cli" },
                "-cli-config",
                path.concat { root_dir, "arduino-cli.yaml" },
            },
        },
    }
end
