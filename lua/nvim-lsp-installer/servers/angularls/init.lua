local server = require "nvim-lsp-installer.server"
local npm = require "nvim-lsp-installer.installers.npm"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://angular.io/guide/language-service",
        languages = { "angular" },
        installer = npm.packages { "@angular/language-server", "typescript" },
        default_options = {
            on_new_config = function(new_config, new_root_dir)
                new_config.cmd = {
                    npm.executable(root_dir, "ngserver"),
                    "--stdio",
                    "--tsProbeLocations",
                    table.concat({ root_dir, new_root_dir }, ","),
                    "--ngProbeLocations",
                    table.concat({ root_dir, new_root_dir }, ","),
                }
            end,
        },
    }
end
