local server = require "nvim-lsp-installer.server"
local path = require "nvim-lsp-installer.path"
local github = require "nvim-lsp-installer.core.managers.github"
local std = require "nvim-lsp-installer.core.managers.std"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://1c-syntax.github.io/bsl-language-server",
        languages = { "onescript" },
        async = true,
        installer = function()
            std.ensure_executable "java"
            local source = github.release_file {
                repo = "1c-syntax/bsl-language-server",
                asset_file = function(release)
                    local version = release:gsub("^v", "")
                    return ("bsl-language-server-%s-exec.jar"):format(version)
                end,
            }
            source.with_receipt()
            std.download_file(source.download_url, "bsl-lsp.jar")
        end,
        default_options = {
            cmd = {
                "java",
                "-jar",
                path.concat { root_dir, "bsl-lsp.jar" },
            },
        },
    }
end
