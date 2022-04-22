local server = require "nvim-lsp-installer.server"
local pip3 = require "nvim-lsp-installer.core.managers.pip3"
local process = require "nvim-lsp-installer.process"
local notify = require "nvim-lsp-installer.notify"

return function(name, root_dir)
    return server.Server:new {
        name = name,
        root_dir = root_dir,
        languages = { "sphinx" },
        homepage = "https://pypi.org/project/esbonio/",
        async = true,
        installer = pip3.packages { "esbonio" },
        default_options = {
            cmd_env = pip3.env(root_dir),
            commands = {
                EsbonioInstallPlugins = {
                    function(requirements_path)
                        if requirements_path == nil then
                            requirements_path = vim.fn.getcwd() .. "/requirements.txt"
                        end
                        notify(("Installing sphinx plugins by %q..."):format(requirements_path))
                        process.spawn(
                            "pip",
                            {
                                args = { "install", "-r", requirements_path },
                                stdio_sink = process.simple_sink(),
                                env = process.graft_env(pip3.env(root_dir)),
                            },
                            vim.schedule_wrap(function(success)
                                if success then
                                    notify(("Successfully installed %q"):format(requirements_path))
                                else
                                    notify("Failed to install requested plugins.", vim.log.levels.ERROR)
                                end
                            end)
                        )
                    end,
                    description = "Installs the plugins for esbonio",
                },
            },
        },
    }
end
