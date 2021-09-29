local server = require "nvim-lsp-installer.server"
local path = require "nvim-lsp-installer.path"
local std = require "nvim-lsp-installer.installers.std"
local context = require "nvim-lsp-installer.installers.context"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        installer = {
            context.github_release_file("rescript-lang/rescript-vscode", function(version)
                return ("rescript-vscode-%s.vsix"):format(version)
            end),
            context.wrap(function(ctx)
                return std.unzip_remote(ctx.github_release_file)
            end),
        },
        default_options = {
            cmd = { "node", path.concat { root_dir, "extension", "server", "out", "server.js" }, "--stdio" },
        },
    }
end
