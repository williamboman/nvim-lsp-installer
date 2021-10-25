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

--- Opens the status window.
function M.display()
    status_win().open()
end

---@param msg string
---@param code number @Exit code to use if in a headless environment.
local function exit(msg, code)
    local is_headless = #vim.api.nvim_list_uis() == 0
    if is_headless then
        vim.schedule(function ()
            -- We schedule the exit to make sure the call stack is exhausted
            os.exit(code or 1)
        end)
    end
    error(msg)
end

---Installs the provided servers synchronously (blocking call). It's recommended to only use this in headless environments.
---@param server_identifiers string[] @A list of server identifiers (for example {"rust_analyzer@nightly", "tsserver"}).
function M.install_sync(server_identifiers)
    local completed_servers = {}
    local failed_servers = {}
    local server_tuples = {}

    -- Collect all servers and exit early if unable to find one.
    for _, server_identifier in pairs(server_identifiers) do
        local server_name, version = servers.parse_server_identifier(server_identifier)
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

    for _, server in pairs(completed_servers) do
        vim.api.nvim_out_write(("Server %q was successfully installed.\n"):format(server.name))
    end
end

---Unnstalls the provided servers synchronously (blocking call). It's recommended to only use this in headless environments.
---@param server_identifiers string[] @A list of server identifiers (for example {"rust_analyzer@nightly", "tsserver"}).
function M.uninstall_sync(server_identifiers)
    for _, server_identifier in pairs(server_identifiers) do
        local server_name = servers.parse_server_identifier(server_identifier)
        local ok, server = servers.get_server(server_name)
        if not ok then
            vim.api.nvim_err_writeln(server)
            exit(("Could not find server %q."):format(server_name))
        end
        local uninstall_ok, uninstall_error = pcall(server.uninstall, server)
        if not uninstall_ok then
            vim.api.nvim_err_writeln(tostring(uninstall_error))
            exit(("Failed to uninstall server %q."):format(server.name))
        end
        print(("Successfully uninstalled server %q."):format(server.name))
    end
end

--- Queues a server to be installed. Will also open the status window.
--- Use the .on_server_ready(cb) function to register a handler to be executed when a server is ready to be set up.
---@param server_identifier string @The server to install. This can also include a requested version, for example "rust_analyzer@nightly".
function M.install(server_identifier)
    local server_name, version = servers.parse_server_identifier(server_identifier)
    local ok, server = servers.get_server(server_name)
    if not ok then
        return notify(("Unable to find LSP server %s.\n\n%s"):format(server_name, server), vim.log.levels.ERROR)
    end
    status_win().install_server(server, version)
    status_win().open()
end

--- Queues a server to be uninstalled. Will also open the status window.
---@param server_name string The server to uninstall.
function M.uninstall(server_name)
    local ok, server = servers.get_server(server_name)
    if not ok then
        return notify(("Unable to find LSP server %s.\n\n%s"):format(server_name, server), vim.log.levels.ERROR)
    end
    status_win().uninstall_server(server)
    status_win().open()
end

--- Queues all servers to be uninstalled. Will also open the status window.
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
        local ok, err = pcall(fs.rmrf, settings.current.install_root_dir)
        if not ok then
            vim.api.nvim_err_writeln(err)
            exit "Failed to uninstall all servers."
        end
    end
    print "Successfully uninstalled all servers."
    status_win().mark_all_servers_uninstalled()
    status_win().open()
end

---@param cb fun(server: Server) @Callback to be executed whenever a server is ready to be set up.
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
