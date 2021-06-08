local shell = require("nvim-lsp-installer.installers.shell")

local M = {}

function M.packages(packages)
    return function (server, callback)
        if vim.g.lsp_installer_use_yarn then
            shell.raw(("yarn add %s"):format(table.concat(packages, " ")))(server, callback)
        else
            shell.raw(("npm install %s"):format(table.concat(packages, " ")))(server, callback)
        end
    end
end

return M
