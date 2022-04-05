local server = require "nvim-lsp-installer.server"
local npm = require "nvim-lsp-installer.core.managers.npm"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        deprecated = {
            message = "ocamlls is deprecated, use ocamllsp instead.",
            replace_with = "ocamllsp",
        },
        homepage = "https://github.com/ocaml-lsp/ocaml-language-server",
        languages = { "ocaml" },
        installer = npm.packages { "ocaml-language-server" },
        async = true,
        default_options = {
            cmd_env = npm.env(root_dir),
        },
    }
end
