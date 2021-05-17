local server = require("nvim-lsp-installer.server")
local path = require("nvim-lsp-installer.path")
local zx = require("nvim-lsp-installer.installers.zx")

local root_dir = server.get_server_root_path("c-family")

return server.Server:new {
  name = "clangd",
  root_dir = root_dir,
  install_cmd = zx.file("./install.mjs"),
  default_options = {
    cmd = { path.concat { root_dir, "clangd", "bin", "clangd" } },
  }
}
