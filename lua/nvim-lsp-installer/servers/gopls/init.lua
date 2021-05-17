local server = require("nvim-lsp-installer.server")
local path = require("nvim-lsp-installer.path")
local shell = require("nvim-lsp-installer.installers.shell")

local root_dir = server.get_server_root_path("go")

local install_cmd = [=[
GO111MODULE=on GOBIN="$PWD" GOPATH="$PWD"  go get golang.org/x/tools/gopls@latest;
command -v ./gopls &> /dev/null; 
]=]

return server.Server:new {
  name = "gopls",
  root_dir = root_dir,
  pre_install_check = function ()
    if vim.fn.executable("go") ~= 1 then
      error("Please install the Go CLI before installing gopls (https://golang.org/doc/install).")
    end
  end,
  installer = shell.raw(install_cmd),
  default_options = {
    cmd = { path.concat { root_dir, "gopls" } },
  }
}
