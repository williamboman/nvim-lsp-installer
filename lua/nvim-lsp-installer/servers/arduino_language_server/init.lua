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
    local arduino_cli_installer = installers.branch_context {
        context.set_working_dir "arduino-cli",
        context.set(function(ctx)
            -- The user's requested version should not apply to the CLI.
            ctx.requested_server_version = nil
        end),
        context.use_github_release_file("arduino/arduino-cli", function(version)
            local target_file = coalesce(
                when(platform.is_mac, "arduino-cli_%s_macOS_64bit.tar.gz"),
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
                return std.unzip_remote(ctx.github_release_file)
            else
                return std.untargz_remote(ctx.github_release_file)
            end
        end),
        std.chmod("+x", { "arduino-cli" }),
        ---@type ServerInstallerFunction
        function(_, callback, ctx)
            process.spawn(path.concat { ctx.install_dir, "arduino-cli" }, {
                args = { "config", "init", "--dest-file", "arduino-cli.yaml", "--overwrite" },
                cwd = ctx.install_dir,
                stdio_sink = ctx.stdio_sink,
            }, callback)
        end,
        context.receipt(function(receipt, ctx)
            receipt:with_secondary_source(receipt.github_release_file(ctx))
        end),
    }

    local arduino_language_server_installer = installers.branch_context {
        context.set_working_dir "arduino-language-server",
        go.packages { "github.com/arduino/arduino-language-server" },
    }

    local clangd_installer = installers.branch_context {
        context.set(function(ctx)
            -- The user's requested version should not apply to clangd.
            ctx.requested_server_version = nil
        end),
        context.use_github_release_file("clangd/clangd", function(version)
            local target_file = coalesce(
                when(platform.is_mac, "clangd-mac-%s.zip"),
                when(platform.is_linux and platform.arch == "x64", "clangd-linux-%s.zip"),
                when(platform.is_win, "clangd-windows-%s.zip")
            )
            return target_file and target_file:format(version)
        end),
        context.capture(function(ctx)
            return installers.pipe {
                std.unzip_remote(ctx.github_release_file),
                std.rename(("clangd_%s"):format(ctx.requested_server_version), "clangd"),
            }
        end),
        context.receipt(function(receipt, ctx)
            receipt:with_secondary_source(receipt.github_release_file(ctx))
        end),
    }

    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://github.com/arduino/arduino-language-server",
        languages = { "arduino" },
        installer = {
            clangd_installer,
            arduino_cli_installer,
            arduino_language_server_installer,
            context.receipt(function(receipt)
                -- We install 3 different components to 3 different subdirectories. This is currently not captured in
                -- the receipt structure.
                receipt:mark_invalid()
            end),
        },
        default_options = {
            cmd = {
                -- This cmd is incomplete. Users need to manually append their FQBN (e.g., -fqbn arduino:avr:nano)
                "arduino-language-server",
                "-cli",
                path.concat { root_dir, "arduino-cli", platform.is_win and "arduino-cli.exe" or "arduino-cli" },
                "-cli-config",
                path.concat { root_dir, "arduino-cli", "arduino-cli.yaml" },
                "-clangd",
                path.concat { root_dir, "clangd", "bin", platform.is_win and "clangd.bat" or "clangd" },
            },
            cmd_env = go.env(path.concat { root_dir, "arduino-language-server" }),
        },
    }
end
