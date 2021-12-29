local server = require "nvim-lsp-installer.server"
local Data = require "nvim-lsp-installer.data"
local context = require "nvim-lsp-installer.installers.context"
local platform = require "nvim-lsp-installer.platform"
local std = require "nvim-lsp-installer.installers.std"
local path = require "nvim-lsp-installer.path"

local coalesce, when = Data.coalesce, Data.when

return function(name, root_dir)
    local bin_name = platform.is_win and "solc.exe" or "solc"
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://github.com/ethereum/solidity",
        languages = { "solidity" },
        installer = {
            context.use_github_release_file(
                "ethereum/solidity",
                coalesce(
                    when(platform.is_mac, "solc-macos"),
                    when(platform.is_linux, "solc-static-linux"),
                    when(platform.is_win, "solc-windows.exe")
                )
            ),
            context.capture(function(ctx)
                return std.download_file(ctx.github_release_file, bin_name)
            end),
            std.chmod("+x", { bin_name }),
        },
        default_options = {
            cmd = { path.concat { root_dir, bin_name } },
        },
    }
end
