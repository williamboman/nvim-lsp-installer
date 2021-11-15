local server = require "nvim-lsp-installer.server"
local npm = require "nvim-lsp-installer.installers.npm"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://github.com/rcjsuen/dockerfile-language-server-nodejs",
        languages = { "docker" },
        installer = npm.packages { "dockerfile-language-server-nodejs" },
        default_options = {
            cmd = { npm.executable(root_dir, "docker-langserver"), "--stdio" },
        },
    }
end
