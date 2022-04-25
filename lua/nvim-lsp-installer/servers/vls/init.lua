local lspconfig = require "lspconfig"
local configs = require "lspconfig.configs"
local servers = require "nvim-lsp-installer.servers"
local server = require "nvim-lsp-installer.server"
local path = require "nvim-lsp-installer.path"
local shell = require "nvim-lsp-installer.installers.shell"


return function(name, root_dir)
    local server_name = "vls"

    local root_dir = server.get_server_root_path(server_name)

    local vls_installer = shell.bash [[
# Must be cloned with git, since the VLS installer requires it
# See build.vsh in vlang/vls
    git clone https://github.com/vlang/vls.git && cd vls

# Build with v
    if type clang
    then
        v run build.vsh clang
    elif type gcc
    then
        v run build.vsh gcc
    elif type cc
    then
        v run build.vsh cc
    elif type msvc
    then
        v run build.vsh cc
    else
        echo "Failed to find a compiler"
        exit 1
    fi
]]

    -- 2. (mandatory) Create an nvim-lsp-installer Server instance
    local vls_server = server.Server:new {
        name = server_name,
        root_dir = root_dir,
        homepage = "https://github.com/vlang/vls",
        languages = {"vlang"},
        installer = vls_installer,
        default_options = {
            cmd = { path.concat { root_dir, "vls/bin/vls" } },
        },
    }
    return vls_server
end
