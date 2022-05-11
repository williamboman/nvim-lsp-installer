local server = require "nvim-lsp-installer.server"
local platform = require "nvim-lsp-installer.core.platform"
local path = require "nvim-lsp-installer.core.path"
local functional = require "nvim-lsp-installer.core.functional"
local github = require "nvim-lsp-installer.core.managers.github"
local std = require "nvim-lsp-installer.core.managers.std"

local coalesce, when = functional.coalesce, functional.when

local generate_cmd = function(root_dir)
  if vim.fn.executable("mono") then
    return {
      "mono",
      path.concat { root_dir, "omnisharp-mono", "OmniSharp.exe" },
      "--languageserver",
      "--hostPID",
      tostring(vim.fn.getpid()),
    }
  else
    return {
      "dotnet",
      path.concat { root_dir, "omnisharp", "OmniSharp.dll" },
      "--languageserver",
      "--hostPID",
      tostring(vim.fn.getpid()),
    }
  end
end

return function(name, root_dir)
  return server.Server:new {
    name = name,
    root_dir = root_dir,
    homepage = "https://github.com/OmniSharp/omnisharp-roslyn",
    languages = { "c#" },
    ---@param ctx InstallContext
    installer = function(ctx)
      std.ensure_executable("mono", { help_url = "https://www.mono-project.com/download/stable/" })

      -- We write to the omnisharp directory for backwards compatibility reasons
      ctx.fs:mkdir "omnisharp"
      ctx:chdir("omnisharp", function()
        github.unzip_release_file({
          repo = "OmniSharp/omnisharp-roslyn",
          asset_file = coalesce(
            when(
              platform.is_mac,
              coalesce(
                when(platform.arch == "x64", "omnisharp-osx-x64-net6.0.zip"),
                when(platform.arch == "arm64", "omnisharp-osx-arm64-net6.0.zip")
              )
            ),
            when(
              platform.is_linux,
              coalesce(
                when(platform.arch == "x64", "omnisharp-linux-x64-net6.0.zip"),
                when(platform.arch == "arm64", "omnisharp-linux-arm64-net6.0.zip")
              )
            ),
            when(
              platform.is_win,
              coalesce(
                when(platform.arch == "x64", "omnisharp-win-x64-net6.0.zip"),
                when(platform.arch == "arm64", "omnisharp-win-arm64-net6.0.zip")
              )
            )
          ),
        }).with_receipt()
      end)

      ctx.fs:mkdir "omnisharp-mono"
      ctx:chdir("omnisharp-mono", function()
        github.unzip_release_file({
          repo = "OmniSharp/omnisharp-roslyn",
          asset_file = "omnisharp-mono.zip",
        }).with_receipt()
      end)
    end,
    default_options = {
      on_new_config = function(config)
        config.cmd = generate_cmd(root_dir)
      end
    },
  }
end
