local server = require "nvim-lsp-installer.server"
local path = require "nvim-lsp-installer.path"
local Data = require "nvim-lsp-installer.data"
local std = require "nvim-lsp-installer.installers.std"
local platform = require "nvim-lsp-installer.platform"
local context = require "nvim-lsp-installer.installers.context"

local coalesce, when = Data.coalesce, Data.when

return function(name, root_dir)
    local lsp_name = "slint-lsp/slint-lsp"

    local archive_name = coalesce(
        when(platform.is_linux and platform.arch == "x64", "slint-lsp-linux.tar.gz"),
        when(platform.is_win and platform.arch == "x64", "slint-lsp-windows.zip")
    )
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://slint-ui.com/",
        languages = { "slint" },
        installer = {
            context.use_github_release_file("slint-ui/slint", archive_name),
            context.capture(function(ctx)
                if platform.is_win then
                    return std.unzip_remote(ctx.github_release_file)
                else
                    return std.untargz_remote(ctx.github_release_file)
                end
            end),
            std.chmod("+x", { lsp_name }),
        },
        default_options = {
            cmd = { path.concat { root_dir, lsp_name } },
        },
    }
end
