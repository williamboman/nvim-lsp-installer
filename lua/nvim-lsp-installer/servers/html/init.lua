local server = require("nvim-lsp-installer.server")
local path = require("nvim-lsp-installer.path")
local npm = require("nvim-lsp-installer.installers.npm")

local root_dir = server.get_server_root_path("html")

return server.Server:new {
    name = "html",
    root_dir = root_dir,
    install_cmd = npm.packages { "vscode-html-languageserver-bin" },
    default_options = {
        cmd = { path.concat { root_dir, "node_modules", ".bin", "html-languageserver" }, "--stdio" },
    },
}
