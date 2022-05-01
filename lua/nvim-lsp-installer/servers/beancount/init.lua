local server = require "nvim-lsp-installer.server"
local pip3 = require "nvim-lsp-installer.core.managers.pip3"
local Data = require "nvim-lsp-installer.data"
local platform = require "nvim-lsp-installer.platform"
local cargo = require "nvim-lsp-installer.core.managers.cargo"
local path = require "nvim-lsp-installer.path"
local process = require "nvim-lsp-installer.process"

local coalesce, when = Data.coalesce, Data.when

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        languages = { "beancount" },
        homepage = "https://github.com/polarmutex/beancount-language-server",
        async = true,
        ---@param ctx InstallContext
        installer = cargo.crate("beancount-language-server"),
        default_options = {
            cmd_env = cargo.env(root_dir)
        },
    }
end
