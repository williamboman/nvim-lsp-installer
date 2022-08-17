local server = require "nvim-lsp-installer.server"
local npm = require "nvim-lsp-installer.core.managers.npm"
local util = require "lspconfig.util"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://github.com/nrwl/nx-console",
        languages = { "json", "jsonc" },
        installer = npm.packages { "nxls" },
        default_options = {
            cmd_env = npm.env(root_dir),
        },
    }
end
