local server = require "nvim-lsp-installer.server"
local cargo = require "nvim-lsp-installer.core.managers.cargo"
local lspconfig = require "lspconfig"
local configs = require "lspconfig.configs"

if not configs.wgsl_analyzer then
    configs.wgsl_analyzer = {
        default_config = {
            cmd = { "wgsl_analyzer" },
            filetypes = { "wgsl" },
            root_dir = lspconfig.util.root_pattern(".git", "wgsl"),
            settings = {}
        }
    }
end

return function(name, root_dir)
    local homepage = "https://github.com/wgsl-analyzer/wgsl-analyzer"

    return server.Server:new {
        name = name,
        root_dir = root_dir,
        languages = { "wgsl" },
        homepage = homepage,
        installer = cargo.crate("wgsl_analyzer", {
            git = homepage
        }),
        default_options = {
            cmd_env = cargo.env(root_dir),
        },
    }
end
