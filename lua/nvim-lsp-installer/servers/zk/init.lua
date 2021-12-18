local server = require "nvim-lsp-installer.server"
local std = require "nvim-lsp-installer.installers.std"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://https://github.com/mickael-menu/zk",
        languages = { "markdown" },
        installer = std.ensure_executables {
            {
                "zk",
                "zk was not found in path. Refer to https://github.com/mickael-menu/zk#install.",
            },
        },
        default_options = {},
    }
end
