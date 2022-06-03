local server = require "nvim-lsp-installer.server"
local github = require "nvim-lsp-installer.core.managers.github"
local git = require "nvim-lsp-installer.core.managers.git"
local Optional = require "nvim-lsp-installer.core.optional"
local path = require "nvim-lsp-installer.core.path"

return function(name, root_dir)
    local JAR_FILE = "apex-jorje-lsp.jar"

    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://github.com/forcedotcom/salesforcedx-vscode",
        languages = { "apex" },
        ---@async
        ---@param ctx InstallContext
        installer = function(ctx)
            local source = github.tag { repo = "forcedotcom/salesforcedx-vscode" }
            source.with_receipt()
            git.clone { "https://github.com/forcedotcom/salesforcedx-vscode", version = Optional.of(source.tag) }
            ctx.fs:rename(
                path.concat {
                    "packages",
                    "salesforcedx-vscode-apex",
                    "out",
                    JAR_FILE,
                },
                JAR_FILE
            )
        end,
        default_options = {
            apex_jar_path = path.concat { root_dir, JAR_FILE },
        },
    }
end
