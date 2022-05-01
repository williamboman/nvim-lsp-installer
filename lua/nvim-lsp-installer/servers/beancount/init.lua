local server = require "nvim-lsp-installer.server"
local Data = require "nvim-lsp-installer.data"
local cargo = require "nvim-lsp-installer.core.managers.cargo"

local coalesce, when = Data.coalesce, Data.when

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        languages = { "beancount" },
        homepage = "https://github.com/polarmutex/beancount-language-server",
        async = true,
        installer = cargo.crate("beancount-language-server"),
        default_options = {
            cmd_env = cargo.env(root_dir)
        },
    }
end
