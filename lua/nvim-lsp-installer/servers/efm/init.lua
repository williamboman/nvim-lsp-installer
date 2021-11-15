local server = require "nvim-lsp-installer.server"
local go = require "nvim-lsp-installer.installers.go"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://github.com/mattn/efm-langserver",
        languages = {},
        installer = go.packages { "github.com/mattn/efm-langserver" },
        default_options = {
            cmd = { go.executable(root_dir, "efm-langserver") },
        },
    }
end
