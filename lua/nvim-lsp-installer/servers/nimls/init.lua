local server = require "nvim-lsp-installer.server"
local shell = require "nvim-lsp-installer.installers.shell"

return function(name, root_dir)
  return server.Server:new {
    name = name,
    root_dir = root_dir,
    homepage = "https://github.com/PMunch/nimlsp",
    languages = { "nim" },
    installer = {
      shell.bash [[ 
        git clone --depth 1 https://github.com/PMunch/nimlsp.git .
        nimble build
      ]]
    },
    default_options = {
      cmd = { root_dir.."/nimlsp" },
      filetypes = { "nim" },
    },
  }
end
