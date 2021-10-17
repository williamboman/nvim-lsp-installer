local server = require "nvim-lsp-installer.server"
local npm = require "nvim-lsp-installer.installers.npm"

local function get_command(root_dir, executable)
    local cmd = npm.executable(root_dir, executable)

    -- If we have yarn installed execute the lsp wrapped with yarn node to
    -- avoid issues resolving modules in yarn 2 repo's
    if vim.fn.executable('yarn') == 1 then
        return {'yarn', 'node', cmd, '--stdio'}
    end
    return {cmd, '--stdio'}

end

return function(executable)
    return function(name, root_dir)
        return server.Server:new{
            name = name,
            root_dir = root_dir,
            installer = npm.packages {"vscode-langservers-extracted"},
            default_options = {cmd = get_command(root_dir, executable)}
        }
    end
end
