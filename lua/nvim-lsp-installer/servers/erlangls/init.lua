local server = require "nvim-lsp-installer.server"
local path = require "nvim-lsp-installer.path"
local shell = require "nvim-lsp-installer.installers.shell"
local std = require "nvim-lsp-installer.installers.std"
local lspconfig = require "lspconfig/util"

return function(name, root_dir)
  return server.Server:new {
    name = name,
    root_dir = root_dir,
    installer = {
      shell.bash("git clone --depth 1 https://github.com/erlang-ls/erlang_ls.git . && make && cp _build/default/bin/erlang_ls ."),
      std.chmod("+x", { "erlang_ls"} ),
    },
    default_options = {
      cmd = { path.concat { root_dir, "erlang_ls" }},
      filetypes = { "erlang" },
      root_dir = lspconfig.root_pattern('rebar.config', 'erlang.mk', '.git') or lspconfig.path.dirname(fname)
    },
  }
end
