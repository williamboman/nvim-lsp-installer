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
        installer = function(ctx)
            cargo.install("beancount-language-server").with_receipt()
            pip3.install { "beancount" }
            ctx.receipt:with_secondary_source(ctx.receipt.pip3 "beancount")
        end,
        default_options = {
            cmd_env = {
                PATH = process.extend_path { path.concat { root_dir, "bin" }, pip3.venv_path(root_dir) },
            },
        },
    }
end
