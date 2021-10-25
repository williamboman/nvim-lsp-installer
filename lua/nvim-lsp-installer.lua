local fs = require "nvim-lsp-installer.fs"
local notify = require "nvim-lsp-installer.notify"
local dispatcher = require "nvim-lsp-installer.dispatcher"
local process = require "nvim-lsp-installer.process"
local status_win = require "nvim-lsp-installer.ui.status-win"
local servers = require "nvim-lsp-installer.servers"
local settings = require "nvim-lsp-installer.settings"
local log = require "nvim-lsp-installer.log"

local M = {}

M.settings = settings.set

function M.display()
    status_win().open()
end

local function exit(msg, code)
    local is_headless = #vim.api.nvim_list_uis() == 0
    if is_headless then
        vim.api.nvim_err_writeln(msg)
        os.exit(code or 1)
    else
        error(msg)
    end
end

function M.install_sync(server_identifiers)
    local completed_servers = {}
    local failed_servers = {}
    local server_tuples = {}

    -- Collect all servers and exit early if unable to find one.
    for _, server_identifier in pairs(server_identifiers) do
        local server_name, version = unpack(servers.parse_server_identifier(server_identifier))
        local ok, server = servers.get_server(server_name)
        if not ok then
            exit(("Could not find server %q."):format(server_name))
        end
        table.insert(server_tuples, { server, version })
    end

    -- Start all installations.
    for _, server_tuple in ipairs(server_tuples) do
        local server, version = unpack(server_tuple)

        server:install_attached({
            stdio_sink = process.simple_sink(),
            requested_server_version = version,
        }, function(success)
            table.insert(completed_servers, server)
            if not success then
                table.insert(failed_servers, server)
            end
        end)
    end

    -- Poll for completion.
    while #completed_servers < #server_identifiers do
        pcall(vim.cmd, [[ sleep 100m ]])
    end

    if #failed_servers > 0 then
        for _, server in pairs(failed_servers) do
            vim.api.nvim_err_writeln(("Server %q failed to install."):format(server.name))
        end
        exit(("%d/%d servers failed to install."):format(#failed_servers, #completed_servers))
    end
end

function M.uninstall_sync(server_identifiers)
    for _, server_identifier in pairs(server_identifiers) do
        local server_name = unpack(servers.parse_server_identifier(server_identifier))
        local ok, server = servers.get_server(server_name)
        if not ok then
            error(("Could not find server %q."):format(server_name))
        end
        if not pcall(server.uninstall, server) then
            exit(("Failed to uninstall server %q."):format(server.name))
        end
        vim.api.nvim_out_write(("Uninstalled server %q.\n"):format(server.name))
    end
end

function M.install(server_identifier)
    local server_name, version = unpack(servers.parse_server_identifier(server_identifier))
    local ok, server = servers.get_server(server_name)
    if not ok then
        return notify(("Unable to find LSP server %s.\n\n%s"):format(server_name, server), vim.log.levels.ERROR)
    end
    status_win().install_server(server, version)
    status_win().open()
end

function M.uninstall(server_name)
    local ok, server = servers.get_server(server_name)
    if not ok then
        return notify(("Unable to find LSP server %s.\n\n%s"):format(server_name, server), vim.log.levels.ERROR)
    end
    status_win().uninstall_server(server)
    status_win().open()
end

function M.uninstall_all(no_confirm)
    if not no_confirm then
        local choice = vim.fn.confirm(
            ("This will uninstall all servers currently installed at %q. Continue?"):format(
                vim.fn.fnamemodify(settings.current.install_root_dir, ":~")
            ),
            "&Yes\n&No",
            2
        )
        if settings.current.install_root_dir ~= settings._DEFAULT_SETTINGS.install_root_dir then
            choice = vim.fn.confirm(
                (
                    "WARNING: You are using a non-default install_root_dir (%q). This command will delete the entire directory. Continue?"
                ):format(vim.fn.fnamemodify(settings.current.install_root_dir, ":~")),
                "&Yes\n&No",
                2
            )
        end
        if choice ~= 1 then
            print "Uninstalling all servers was aborted."
            return
        end
    end

    log.info "Uninstalling all servers."
    if fs.dir_exists(settings.current.install_root_dir) then
        fs.rmrf(settings.current.install_root_dir)
    end
    status_win().mark_all_servers_uninstalled()
    status_win().open()
end

function M.on_server_ready(cb)
    dispatcher.register_server_ready_callback(cb)
    vim.schedule(function()
        local installed_servers = servers.get_installed_servers()
        for i = 1, #installed_servers do
            dispatcher.dispatch_server_ready(installed_servers[i])
        end
    end)
end

-- "Proxy" function for triggering attachment of LSP servers to all buffers (useful when just installed a new server
-- that wasn't installed at launch)
M.lsp_attach_proxy = process.debounced(function()
    -- As of writing, if the lspconfig server provides a filetypes setting, it uses FileType as trigger, otherwise it uses BufReadPost
    vim.cmd [[ doautoall FileType | doautoall BufReadPost ]]
end)

-- old API
M.get_server = servers.get_server
M.get_available_servers = servers.get_available_servers
M.get_installed_servers = servers.get_installed_servers
M.get_uninstalled_servers = servers.get_uninstalled_servers
M.register = servers.register

return M
