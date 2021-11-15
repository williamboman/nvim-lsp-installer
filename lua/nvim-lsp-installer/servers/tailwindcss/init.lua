local server = require "nvim-lsp-installer.server"
local npm = require "nvim-lsp-installer.installers.npm"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        languages = { "tailwind" },
        installer = npm.packages { "@tailwindcss/language-server" },
        default_options = {
            cmd = { npm.executable(root_dir, "tailwindcss-language-server"), "--stdio" },
        },
    }
end
