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
                    ('if (!require("remotes")) { install.packages("remotes", repos="https://cloud.r-project.org") };') ..
                    ('remotes::install_github("REditorSupport/languageserver", upgrade="default", force=TRUE, lib=%q)'):format(
                        root_dir
                    ),
                },
                stdio_sink = context.stdio_sink,
            }, callback)
        end,
        default_options = {
            cmd = {
                "R",
                "--slave",
                "-e",
                ("library(languageserver, lib.loc = %q); languageserver::run()"):format(root_dir),
            },
        },
    }
end
