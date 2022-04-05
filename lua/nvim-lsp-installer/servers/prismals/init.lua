local server = require "nvim-lsp-installer.server"
local npm = require "nvim-lsp-installer.core.managers.npm"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        languages = { "prisma" },
        homepage = "https://github.com/prisma/language-tools",
        installer = npm.packages { "@prisma/language-server" },
        async = true,
        default_options = {
            cmd_env = npm.env(root_dir),
        },
    }
end
