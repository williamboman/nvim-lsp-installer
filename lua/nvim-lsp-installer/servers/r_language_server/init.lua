local server = require "nvim-lsp-installer.server"
local process = require "nvim-lsp-installer.process"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        installer = function(_, callback, context)
            process.spawn("R", {
                args = {
                    "-e",
                    ('install.packages("languageserver", repos="https://cloud.r-project.org", lib=%q)'):format(
                        root_dir
                    ),
                },
                env = process.graft_env {
                    R_LIBS = root_dir,
                    R_LIBS_USER = root_dir,
                    R_LIBS_SITE = root_dir
                },
                stdio_sink = context.stdio_sink,
            }, callback)
        end,
        default_options = {
            cmd_env = {
                R_LIBS = root_dir,
                R_LIBS_USER = root_dir,
                R_LIBS_SITE = root_dir,
            }
        }
    }
end
