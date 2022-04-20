local server = require "nvim-lsp-installer.server"
local path = require "nvim-lsp-installer.path"
local Data = require "nvim-lsp-installer.data"
local platform = require "nvim-lsp-installer.platform"
local process = require "nvim-lsp-installer.process"
local std = require "nvim-lsp-installer.core.managers.std"
local github = require "nvim-lsp-installer.core.managers.github"

local coalesce, when = Data.coalesce, Data.when

return function(name, root_dir)
    ---@async
    local function download_solang()
        local source = github.release_file {
            repo = "hyperledger-labs/solang",
            asset_file = coalesce(
                when(platform.is_mac and platform.arch == "x64", "solang-mac-intel"),
                when(platform.is_mac and platform.arch == "arm64", "solang-mac-arm"),
                when(platform.is_linux and platform.arch == "arm64", "solang-linux-arm64"),
                when(platform.is_linux and platform.arch == "x64", "solang-linux-x86-64"),
                when(platform.is_win, "solang.exe")
            ),
        }
        source.with_receipt()
        std.download_file(source.download_url, platform.is_win and "solang.exe" or "solang")
        std.chmod("+x", { "solang" })
        return source
    end

    ---@async
    local function download_llvm()
        local source = github.release_file {
            repo = "hyperledger-labs/solang",
            asset_file = coalesce(
                when(platform.is_mac and platform.arch == "x64", "llvm13.0-mac-intel.tar.xz"),
                when(platform.is_mac and platform.arch == "arm64", "llvm13.0-mac-arm.tar.xz"),
                when(platform.is_linux and platform.arch == "x64", "llvm13.0-linux-x86-64.tar.xz"),
                when(platform.is_linux and platform.arch == "arm64", "llvm13.0-linux-arm64.tar.xz"),
                when(platform.is_win, "llvm13.0-win.zip")
            ),
        }
        if platform.is_win then
            std.download_file(source.download_url, "llvm.zip")
            std.unzip("llvm.zip", ".")
        else
            std.download_file(source.download_url, "llvm.tar.xz")
            std.untar "llvm.tar.xz"
        end
    end

    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://solang.readthedocs.io/en/latest/",
        languages = { "solidity" },
        async = true,
        ---@param ctx InstallContext
        installer = function(ctx)
            ctx:run_concurrently { download_solang, download_llvm }
        end,
        default_options = {
            cmd_env = {
                PATH = process.extend_path {
                    path.concat { root_dir },
                    path.concat { root_dir, "llvm13.0", "bin" },
                    path.concat { root_dir, "llvm12.0", "bin" }, -- kept for backwards compatibility
                },
            },
        },
    }
end
