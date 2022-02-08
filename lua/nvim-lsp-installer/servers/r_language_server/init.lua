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
            .. 'rlsLib = getOption("langserver_library")'
            .. ';'
            .. 'install.packages("languageserversetup", lib = rlsLib)'
            .. ';'
            .. 'loadNamespace("languageserversetup", lib.loc = rlsLib)'
            .. ';'
            .. [[languageserversetup::languageserver_install(
              fullReinstall = FALSE,
              confirmBeforeInstall = FALSE,
              strictLibrary = FALSE,
              libs_only = TRUE
            )]],
        },
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
