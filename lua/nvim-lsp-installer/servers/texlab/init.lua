local server = require "nvim-lsp-installer.server"
local path = require "nvim-lsp-installer.path"
local std = require "nvim-lsp-installer.installers.std"
local context = require "nvim-lsp-installer.installers.context"
local Data = require "nvim-lsp-installer.data"
local platform = require "nvim-lsp-installer.platform"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        installer = {
            std.ensure_executables {
                { "pdflatex", "A TeX distribution is not installed. Refer to https://www.latex-project.org/get/." },
            },
            context.github_release_file(
                "latex-lsp/texlab",
                Data.coalesce(
                    Data.when(platform.is_mac, "texlab-x86_64-macos.tar.gz"),
                    Data.when(platform.is_linux, "texlab-x86_64-linux.tar.gz"),
                    Data.when(platform.is_win, "texlab-x86_64-windows.tar.gz")
                )
            ),
            context.wrap(function(ctx)
                return std.untargz_remote(ctx.github_release_file)
            end),
        },
        default_options = {
            cmd = { path.concat { root_dir, "texlab" } },
        },
    }
end
