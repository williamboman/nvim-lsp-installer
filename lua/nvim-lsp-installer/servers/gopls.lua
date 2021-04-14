local server = require('nvim-lsp-installer.server')

local root_dir = server.get_server_root_path('go')

local install_cmd = [=[
if ! command -v go &> /dev/null;
then 
  echo "Please install the Go CLI before installing gopls.";
  echo "refer to https://golang.org/doc/install";
  exit 1;
fi

GO111MODULE=on go get golang.org/x/tools/gopls@latest;

if ! command -v gopls &> /dev/null; 
then 
  echo "something went wrong!"
else 
  echo "installation completed"
fi

]=]

return server.Server:new {
  name = "gopls",
  root_dir = root_dir,
  install_cmd = install_cmd,
  default_options = {
    cmd = {"gopls"},
  }
}
