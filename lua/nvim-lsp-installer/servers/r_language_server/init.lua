local server = require 'nvim-lsp-installer.server'
local shell = require "nvim-lsp-installer.installers.shell"
local path = require "nvim-lsp-installer.path"

local root_dir = server.get_server_root_path("r_language_server")

return server.Server:new {
    name = "r_language_server",
    root_dir = root_dir,
    installer = shell.polyshell([[R -e 'install.packages("languageserver", repos="http://cran.us.r-project.org")']]),
    default_options = {
        cmd = {
            'R', '--slave', '-e', 'languageserver::run()'
        }
    }
}
