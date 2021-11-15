local server = require "nvim-lsp-installer.server"
local npm = require "nvim-lsp-installer.installers.npm"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        languages = { "vim" },
        homepage = "https://github.com/iamcco/vim-language-server",
        installer = npm.packages { "vim-language-server" },
        default_options = {
            cmd = { npm.executable(root_dir, "vim-language-server"), "--stdio" },
        },
    }
end
