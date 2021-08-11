local server = require("nvim-lsp-installer.server")
local path = require("nvim-lsp-installer.path")
local shell = require("nvim-lsp-installer.installers.shell")

local root_dir = server.get_server_root_path("ansiblels")

return server.Server:new {
    name = "ansiblels",
    root_dir = root_dir,
    installer = shell.raw [[
    git clone --depth 1 https://github.com/ansible/ansible-language-server .;
    yarn install;
    yarn build;
    yarn install --production;
    ]],
    default_options = {
        filetypes = { "yaml", "yaml.ansible" },
        cmd = { "node", path.concat { root_dir, "out", "server", "src", "server.js" }, "--stdio" },
    }
}
