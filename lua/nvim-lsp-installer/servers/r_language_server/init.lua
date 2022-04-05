local server = require "nvim-lsp-installer.server"

return function(name, root_dir)
    local function windows_path_unescape(str)
        return str:gsub("\\", "/")
    end

    local function create_install_script(install_dir)
        return ([[
options(langserver_library = %q);
options(repos = list(CRAN = "http://cran.rstudio.com/"));
rlsLib <- getOption("langserver_library");
install.packages("languageserversetup", lib = rlsLib);
loadNamespace("languageserversetup", lib.loc = rlsLib);

languageserversetup::languageserver_install(
    fullReinstall = TRUE,
    confirmBeforeInstall = FALSE,
    strictLibrary = TRUE
);
]]):format(windows_path_unescape(install_dir), windows_path_unescape(install_dir), windows_path_unescape(install_dir))
    end

    local server_script = ([[
options("langserver_library" = %q);
rlsLib <- getOption("langserver_library");
.libPaths(new = rlsLib);
loadNamespace("languageserver", lib.loc = rlsLib);
languageserver::run();
  ]]):format(windows_path_unescape(root_dir))

    return server.Server:new {
        name = name,
        root_dir = root_dir,
        homepage = "https://github.com/REditorSupport/languageserver",
        languages = { "R" },
        async = true,
        installer = function(ctx)
            ctx.spawn.R {
                "--no-save",
                on_spawn = function (_, stdio)
                    local stdin = stdio[1]
                    stdin:write(create_install_script(ctx.cwd:get()))
                    stdin:close()
                end
            }
            ctx.receipt:with_primary_source(ctx.receipt.r_package "languageserver")
        end,
        default_options = {
            cmd = { "R", "--slave", "-e", server_script },
        },
    }
end
