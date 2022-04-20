local path = require "nvim-lsp-installer.path"
local server = require "nvim-lsp-installer.server"
local platform = require "nvim-lsp-installer.platform"
local Data = require "nvim-lsp-installer.data"
local installer = require "nvim-lsp-installer.core.installer"
local github = require "nvim-lsp-installer.core.managers.github"
local go = require "nvim-lsp-installer.core.managers.go"
local std = require "nvim-lsp-installer.core.managers.std"
local Optional = require "nvim-lsp-installer.core.optional"

local coalesce, when = Data.coalesce, Data.when

return function(name, root_dir)
    ---@async
    local function arduino_cli_installer()
        local ctx = installer.context()

        ctx.fs:mkdir "arduino-cli"
        ctx:chdir("arduino-cli", function()
            local opts = {
                repo = "arduino/arduino-cli",
                version = Optional.empty(),
                asset_file = function(release)
                    local target = coalesce(
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
                    return target and target:format(release)
                end,
            }

            platform.when {
                unix = function()
                    github.untargz_release_file(opts)
                    std.chmod("+x", { "arduino-cli" })
                end,
                win = function()
                    github.unzip_release_file(opts)
                end,
            }

            ctx.spawn["arduino-cli"] {
                "config",
                "init",
                "--dest-file",
                "arduino-cli.yaml",
                "--overwrite",
                with_paths = { ctx.cwd:get() },
            }
        end)
    end

    local function arduino_language_server_installer()
        local ctx = installer.context()
        ctx.fs:mkdir "arduino-language-server"
        ctx:chdir("arduino-language-server", go.packages { "github.com/arduino/arduino-language-server" })
    end

    local function clangd_installer()
        local ctx = installer.context()

        local source = github.unzip_release_file {
            repo = "clangd/clangd",
            version = Optional.empty(),
            asset_file = function(release)
                local target_file = coalesce(
                    when(platform.is_mac, "clangd-mac-%s.zip"),
                    when(platform.is_linux and platform.arch == "x64", "clangd-linux-%s.zip"),
                    when(platform.is_win, "clangd-windows-%s.zip")
                )
                return target_file and target_file:format(release)
            end,
        }

        ctx.fs:rename(("clangd_%s"):format(source.release), "clangd")
    end

    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://github.com/arduino/arduino-language-server",
        languages = { "arduino" },
        async = true,
        installer = function()
            clangd_installer()
            arduino_cli_installer()
            arduino_language_server_installer()
        end,
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
