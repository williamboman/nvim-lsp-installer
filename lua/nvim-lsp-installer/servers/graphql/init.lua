local server = require "nvim-lsp-installer.server"
local npm = require "nvim-lsp-installer.installers.npm"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        installer = npm.packages { "graphql-language-service-cli", "graphql" },
        default_options = {
            cmd = { npm.executable(root_dir, "graphql-lsp"), "server", "-m", "stream" },
            filetypes = { "typescriptreact", "javascriptreact", "graphql" },
        },
    }
end
