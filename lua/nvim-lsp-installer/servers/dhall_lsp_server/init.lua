local server = require "nvim-lsp-installer.server"
local path = require "nvim-lsp-installer.path"
local process = require "nvim-lsp-installer.process"
local platform = require "nvim-lsp-installer.platform"
local Data = require "nvim-lsp-installer.data"
local std = require "nvim-lsp-installer.core.managers.std"
local github_client = require "nvim-lsp-installer.core.managers.github.client"
local Optional = require "nvim-lsp-installer.core.optional"

local coalesce, when, list_find_first = Data.coalesce, Data.when, Data.list_find_first

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://dhall-lang.org/",
        languages = { "dhall" },
        async = true,
        ---@param ctx InstallContext
        installer = function(ctx)
            local repo = "dhall-lang/dhall-haskell"
            ---@type GitHubRelease
            local gh_release = ctx.requested_version
                :map(function(version)
                    return github_client.fetch_release(repo, version)
                end)
                :or_else_get(function()
                    return github_client.fetch_latest_release(repo)
                end)
                :get_or_throw()

            local asset_name_pattern = assert(
                coalesce(
                    when(platform.is_mac, "dhall%-lsp%-server%-.+%-x86_64%-macos.tar.bz2"),
                    when(platform.is_linux, "dhall%-lsp%-server%-.+%-x86_64%-linux.tar.bz2"),
                    when(platform.is_win, "dhall%-lsp%-server%-.+%-x86_64%-windows.zip")
                )
            )
            local dhall_lsp_server_asset = list_find_first(
                gh_release.assets,
                ---@param asset GitHubReleaseAsset
                function(asset)
                    return asset.name:match(asset_name_pattern)
                end
            )
            Optional.of_nilable(dhall_lsp_server_asset)
                :if_present(
                    ---@param asset GitHubReleaseAsset
                    function(asset)
                        if platform.is_win then
                            std.download_file(asset.browser_download_url, "dhall-lsp-server.zip")
                            std.unzip("dhall-lsp-server.zip", ".")
                        else
                            std.download_file(asset.browser_download_url, "dhall-lsp-server.tar.bz2")
                            std.untar "dhall-lsp-server.tar.bz2"
                            std.chmod("+x", { path.concat { "bin", "dhall-lsp-server" } })
                        end
                        ctx.receipt:with_primary_source {
                            type = "github_release_file",
                            repo = repo,
                            file = asset.browser_download_url,
                            release = gh_release.tag_name,
                        }
                    end
                )
                :or_else_throw "Unable to find the dhall-lsp-server release asset in the GitHub release."
        end,
        default_options = {
            cmd_env = {
                PATH = process.extend_path { path.concat { root_dir, "bin" } },
            },
        },
    }
end
