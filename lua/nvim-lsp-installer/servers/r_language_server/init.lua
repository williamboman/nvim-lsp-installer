local server = require 'nvim-lsp-installer.server'
local path = require "nvim-lsp-installer.path"
local process = require("nvim-lsp-installer.process")

local root_dir = server.get_server_root_path("r_language_server")

return server.Server:new {
    name = "r_language_server",
    root_dir = root_dir,
    installer = function(server, callback, context)
        process.spawn("R", {
          args = { "-e", 'install.packages("languageserver", repos="http://cran.us.r-project.org", lib = "' .. root_dir .. '")' },
          stdio_sink = context.stdio_sink
        }, callback)
    end,
    default_options = {
        cmd = {
            'R', '--slave', '-e', 'library(languageserver, lib.loc = "' .. root_dir .. '"); languageserver::run()'
        }
    }
}
