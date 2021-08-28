local server = require "nvim-lsp-installer.server"
local installers = require "nvim-lsp-installer.installers"
local path = require "nvim-lsp-installer.path"
local zx = require "nvim-lsp-installer.installers.zx"

local root_dir = server.get_server_root_path "omnisharp"

return server.Server:new {
    name = "omnisharp",
    root_dir = root_dir,
    installer = installers.when {
        unix = zx.file "./install.mjs",
    },
    default_options = {
        cmd = {
            path.concat { root_dir, "omnisharp", "run" },
            "--languageserver",
            "--hostPID",
            tostring(vim.fn.getpid()),
        },
    },
}
