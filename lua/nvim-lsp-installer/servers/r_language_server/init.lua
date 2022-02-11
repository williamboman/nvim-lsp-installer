local server = require "nvim-lsp-installer.server"
local process = require "nvim-lsp-installer.process"

return function(name, root_dir)
    local install_script = [[
options(langserver_library = ".");
rlsLib = getOption("langserver_library");
install.packages("languageserversetup", lib = rlsLib);
loadNamespace("languageserversetup", lib.loc = rlsLib);

languageserversetup::languageserver_install(
    fullReinstall = FALSE,
    confirmBeforeInstall = FALSE,
    strictLibrary = FALSE,
    libs_only = TRUE
);
]]

    local server_script = ([[
options("langserver_library" = %q);
rlsLib = getOption("langserver_library");
.libPaths(new = rlsLib);
loadNamespace("languageserver", lib.loc = rlsLib);
languageserver::run();
  ]]):format(root_dir)

    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://github.com/REditorSupport/languageserver",
        languages = { "R" },
        installer = function(_, callback, ctx)
            process.spawn("R", {
                cwd = ctx.install_dir,
                args = {
                    "-e",
                    install_script,
                },
                stdio_sink = ctx.stdio_sink,
            }, callback)
        end,
        default_options = {
            cmd = {
                "R",
                "--slave",
                "-e",
                server_script,
            },
        },
    }
end
