local server = require "nvim-lsp-installer.server"
local platform = require "nvim-lsp-installer.core.platform"
local process = require "nvim-lsp-installer.core.process"
local std = require "nvim-lsp-installer.core.managers.std"
local github_client = require "nvim-lsp-installer.core.managers.github.client"
local path = require "nvim-lsp-installer.core.path"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://haskell-language-server.readthedocs.io/en/latest/",
        languages = { "haskell" },
        ---@param ctx InstallContext
        installer = function(ctx)
            local repo = "haskell/haskell-language-server"
            local release = ctx.requested_version:or_else_get(function()
                return github_client.fetch_latest_release(repo)
                    :map(
                        ---@param release GitHubRelease
                        function(release)
                            return release.tag_name
                        end
                    )
                    :get_or_throw()
            end)

            std.ensure_executable("ghcup", { help_url = "https://www.haskell.org/ghcup/" })
            ctx:promote_cwd()
            ctx.spawn.ghcup { "install", "hls", release, "-i", ctx.cwd:get() }

            ctx.receipt:with_primary_source(ctx.receipt.github_release(repo, release))
        end,
        default_options = {
            lspinfo = function(cfg)
                local extra = {}
                local function on_stdout(_, data, _)
                    local version = data[1]
                    table.insert(extra, "version:   " .. version)
                end

                local opts = {
                    cwd = cfg.cwd,
                    stdout_buffered = true,
                    on_stdout = on_stdout,
                }
                local chanid = vim.fn.jobstart({ path.concat { root_dir, "bin", cfg.cmd[1] }, "--version" }, opts)
                vim.fn.jobwait { chanid }
                return extra
            end,
            cmd_env = {
                PATH = process.extend_path {
                    platform.is_win and root_dir or path.concat { root_dir, "bin" },
                },
            },
        },
    }
end
