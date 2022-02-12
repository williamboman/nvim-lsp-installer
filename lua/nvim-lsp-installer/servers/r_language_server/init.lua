local server = require('nvim-lsp-installer.server')
local process = require('nvim-lsp-installer.process')

return function(name, root_dir)
  return server.Server:new({
    name = name,
    root_dir = root_dir,
    installer = function(_, callback, context)
      process.spawn('R', {
        args = {
          '-e',
          ('options(langserver_library = %q)'):format(root_dir)
            .. ';'
          ('options(configure.vars = list(TMPDIR = %q))'):format(ctx.install_dir)
            .. ';'
            .. ('Sys.getenv(TMPDIR = %q)'):format(ctx.install_dir)
            .. ';'
            .. 'rlsLib = getOption("langserver_library")'
            .. ';'
            .. 'if (!dir.exists(rlsLib)) {dir.create(rlsLib, recursive = TRUE)}'
            .. ';'
            .. 'install.packages("languageserversetup", lib = rlsLib)'
            .. ';'
            .. 'loadNamespace("languageserversetup", lib.loc = rlsLib)'
            .. ';'
            .. [[languageserversetup::languageserver_install(
              fullReinstall = TRUE,
              confirmBeforeInstall = FALSE,
              strictLibrary = TRUE
            )]],
        },
        -- env = process.graft_env {
        --   TMPDIR = install_dir
        -- },
        --
        stdio_sink = context.stdio_sink,
      }, callback)
    end,
    default_options = {
      cmd = {
        'R',
        '--slave',
        '-e',
        ('options("langserver_library" = %q)'):format(root_dir)
          .. ';'
          .. 'rlsLib = getOption("langserver_library")'
          .. ';'
          .. '.libPaths(new = rlsLib)'
          .. ';'
          .. 'loadNamespace("languageserver", lib.loc = rlsLib)'
          .. ';'
          .. 'languageserver::run()',
      },
    },
  })
end
