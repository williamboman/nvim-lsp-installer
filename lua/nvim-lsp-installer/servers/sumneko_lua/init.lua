local server = require "nvim-lsp-installer.server"
local installers = require "nvim-lsp-installer.installers"
local path = require "nvim-lsp-installer.path"
local platform = require "nvim-lsp-installer.platform"
local Data = require "nvim-lsp-installer.data"
local std = require "nvim-lsp-installer.installers.std"
local shell = require "nvim-lsp-installer.installers.shell"

local root_dir = server.get_server_root_path "lua"

local bin_dir = Data.coalesce(
    Data.when(platform.is_mac, "macOS"),
    Data.when(platform.is_unix, "Linux"),
    Data.when(platform.is_win, "Windows")
)

return server.Server:new {
    name = "sumneko_lua",
    root_dir = root_dir,
    installer = installers.join {
        std.download_file("https://github.com/sumneko/vscode-lua/releases/download/v2.3.6/lua-2.3.6.vsix", "lua.vsix"),
        std.unzip("lua.vsix", "."),
        std.delete_file "lua.vsix",
        installers.on {
            -- see https://github.com/sumneko/vscode-lua/pull/43
            unix = shell.bash [[ chmod +x extension/server/bin/macOS/lua-language-server extension/server/bin/Linux/lua-language-server ]],
        },
    },
    default_options = {
        cmd = {
            path.concat { root_dir, "extension", "server", "bin", bin_dir, "lua-language-server" },
            "-E",
            path.concat { root_dir, "extension", "server", "main.lua" },
        },
        settings = {
            Lua = {
                diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = { "vim" },
                },
                workspace = {
                    -- Make the server aware of Neovim runtime files
                    library = {
                        [vim.fn.expand "$VIMRUNTIME/lua"] = true,
                        [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
                    },
                    maxPreload = 10000,
                },
            },
        },
    },
}
