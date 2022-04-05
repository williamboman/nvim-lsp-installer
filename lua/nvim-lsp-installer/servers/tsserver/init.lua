local server = require "nvim-lsp-installer.server"
local npm = require "nvim-lsp-installer.core.managers.npm"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        languages = { "typescript", "javascript" },
        homepage = "https://github.com/typescript-language-server/typescript-language-server",
        installer = npm.packages { "typescript-language-server", "typescript" },
        async = true,
        default_options = {
            cmd_env = npm.env(root_dir),
        },
    }
end
