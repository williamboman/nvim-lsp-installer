local server = require("nvim-lsp-installer.server")
local path = require("nvim-lsp-installer.path")
local shell = require("nvim-lsp-installer.installers.shell")

local root_dir = server.get_server_root_path("groovyls")

return server.Server:new {
    name = "groovyls",
    root_dir = root_dir,
    pre_install_check = function ()
        if vim.fn.executable("javac") ~= 1 then
            error("Missing a Javac installation.")
        end
    end,
    installer = shell.raw [[
    git clone --depth 1 https://github.com/GroovyLanguageServer/groovy-language-server .;
    ./gradlew build;
    ]],
    default_options = {
        cmd = { "java", "-jar", path.concat { root_dir, "groovy-language-server-all.jar" } },
    },
}
