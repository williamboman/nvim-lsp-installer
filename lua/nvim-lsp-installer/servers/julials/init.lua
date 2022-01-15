local server = require "nvim-lsp-installer.server"
local julia = require "nvim-lsp-installer.installers.julia"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://github.com/julia-vscode/LanguageServer.jl",
        languages = { "julia" },
        installer = julia.packages { "LanguageServer" },
        default_options = {
            cmd_env = julia.env(root_dir),
        },
    }
end
