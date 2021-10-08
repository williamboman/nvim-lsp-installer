local Ui = require "nvim-lsp-installer.ui"
local fs = require "nvim-lsp-installer.fs"
local log = require "nvim-lsp-installer.log"
local Data = require "nvim-lsp-installer.data"
local display = require "nvim-lsp-installer.ui.display"
local settings = require "nvim-lsp-installer.settings"
local lsp_servers = require "nvim-lsp-installer.servers"

local HELP_KEYMAP = "?"
local CLOSE_WINDOW_KEYMAP_1 = "<Esc>"
local CLOSE_WINDOW_KEYMAP_2 = "q"

local function ServerGroupHeading(props)
    return Ui.HlTextNode {
        { { props.title, props.highlight or "LspInstallerHeading" }, { (" (%d)"):format(props.count), "Comment" } },
    }
end

local function Indent(children)
    return Ui.CascadingStyleNode({ Ui.CascadingStyle.INDENT }, children)
end

local function Help()
    local keymap_tuples = {
        { "Toggle help", HELP_KEYMAP },
        { "Toggle server info", settings.current.ui.keymaps.toggle_server_expand },
        { "Reinstall server", settings.current.ui.keymaps.reinstall_server },
        { "Uninstall server", settings.current.ui.keymaps.uninstall_server },
        { "Install server", settings.current.ui.keymaps.install_server },
        { "Close window", CLOSE_WINDOW_KEYMAP_1 },
        { "Close window", CLOSE_WINDOW_KEYMAP_2 },
    }

    -- stylua: ignore start
    local cow = {
        { { [[ _______________________________________________________________________ ]], "LspInstallerMuted" } },
        { { [[ < Help sponsor Neovim development! ]], "LspInstallerMuted" }, { "https://github.com/sponsors/neovim", "LspInstallerHighlighted"}, {[[ > ]], "LspInstallerMuted" } },
        { { [[ ----------------------------------------------------------------------- ]], "LspInstallerMuted" } },
        { { [[        \    ,-^-.                                                       ]], "LspInstallerMuted" } },
        { { [[         \   !oYo!                                                       ]], "LspInstallerMuted" } },
        { { [[          \ /./=\.\______                                                ]], "LspInstallerMuted" } },
        { { [[               ##        )\/\                                            ]], "LspInstallerMuted" } },
        { { [[                ||-----w||                                               ]], "LspInstallerMuted" } },
        { { [[                ||      ||                                               ]], "LspInstallerMuted" } },
        { { [[                                                                         ]], "LspInstallerMuted" } },
        { { [[         Cowth Vader (alleged Neovim user)                               ]], "LspInstallerMuted" } },
        { { [[                                                                         ]], "LspInstallerMuted" } },
    }
    -- stylua: ignore end

    return Ui.Node {
        Ui.EmptyLine(),
        Ui.Table(vim.list_extend(
            {
                {
                    { "Keyboard shortcuts", "LspInstallerLabel" },
                },
            },
            Data.list_map(function(keymap_tuple)
                return { { keymap_tuple[1], "LspInstallerMuted" }, { keymap_tuple[2], "LspInstallerHighlighted" } }
            end, keymap_tuples)
        )),
        Ui.EmptyLine(),
        Ui.HlTextNode {
            { { "Problems installing/uninstalling servers", "LspInstallerLabel" } },
            { { "Refer to ", "" }, { ":help nvim-lsp-installer-debugging", "LspInstallerHighlighted" } },
            { { "", "" } },
            { { "Problems with server functionality", "LspInstallerLabel" } },
            { { "Please refer to each language server's own homepage for further assistance.", "LspInstallerMuted" } },
        },
        Ui.EmptyLine(),
        Ui.EmptyLine(),
        Ui.EmptyLine(),
        Ui.HlTextNode(cow),
    }
end

local function Header()
    return Ui.CascadingStyleNode({ Ui.CascadingStyle.CENTERED }, {
        Ui.HlTextNode {
            { { "nvim-lsp-installer", "LspInstallerHeader" } },
            { { ":help nvim-lsp-installer", "Comment" } },
            { { "https://github.com/williamboman/nvim-lsp-installer", "Comment" } },
        },
    })
end

local Seconds = {
    DAY = 86400, -- 60 * 60 * 24
    WEEK = 604800, -- 60 * 60 * 24 * 7
    MONTH = 2419200, -- 60 * 60 * 24 * 7 * 4
    YEAR = 29030400, -- 60 * 60 * 24 * 7 * 4 * 12
}

local function get_relative_install_time(time)
    local now = os.time()
    local delta = math.max(now - time, 0)
    if delta < Seconds.DAY then
        return "today"
    elseif delta < Seconds.WEEK then
        return "this week"
    elseif delta < Seconds.MONTH then
        return "this month"
    elseif delta < (Seconds.MONTH * 2) then
        return "last month"
    elseif delta < Seconds.YEAR then
        return ("%d months ago"):format(math.floor((delta / Seconds.MONTH) + 0.5))
    else
        return "more than a year ago"
    end
end

local function ServerMetadata(server)
    return Ui.Table(Data.list_not_nil(
        Data.lazy(server.metadata.install_timestamp_seconds, function()
            return {
                { "Installation date", "LspInstallerMuted" },
                { get_relative_install_time(server.metadata.install_timestamp_seconds), "" },
            }
        end),
        Data.when(server.is_installed, {
            { "Install directory", "LspInstallerMuted" },
            { server.metadata.install_dir, "" },
        }),
        Data.when(server.metadata.homepage, {
            { "Server homepage", "LspInstallerMuted" },
            { server.metadata.homepage, "" },
        })
    ))
end

local function InstalledServers(servers)
    return Ui.Node(Data.list_map(function(server)
        return Ui.Node {
            Ui.HlTextNode {
                {
                    { settings.current.ui.icons.server_installed, "LspInstallerGreen" },
                    { " " .. server.name, "" },
                },
            },
            Ui.Keybind(settings.current.ui.keymaps.toggle_server_expand, "EXPAND_SERVER", { server.name }),
            Ui.Keybind(settings.current.ui.keymaps.reinstall_server, "INSTALL_SERVER", { server.name }),
            Ui.Keybind(settings.current.ui.keymaps.uninstall_server, "UNINSTALL_SERVER", { server.name }),
            Ui.When(server.is_expanded, function()
                return Indent {
                    ServerMetadata(server),
                }
            end),
        }
    end, servers))
end

local function TailedOutput(server)
    return Ui.HlTextNode(Data.list_map(function(line)
        return { { line, "LspInstallerMuted" } }
    end, server.installer.tailed_output))
end

local function get_last_non_empty_line(output)
    for i = #output, 1, -1 do
        local line = output[i]
        if #line > 0 then
            return line
        end
    end
    return ""
end

local function PendingServers(servers)
    return Ui.Node(Data.list_map(function(server)
        local has_failed = server.installer.has_run or server.uninstaller.has_run
        local note = has_failed and "(failed)" or (server.installer.is_queued and "(queued)" or "(running)")
        return Ui.Node {
            Ui.HlTextNode {
                {
                    {
                        settings.current.ui.icons.server_pending,
                        has_failed and "LspInstallerError" or "LspInstallerOrange",
                    },
                    { " " .. server.name, server.installer.is_running and "" or "LspInstallerMuted" },
                    { " " .. note, "Comment" },
                    {
                        has_failed and "" or (" " .. get_last_non_empty_line(server.installer.tailed_output)),
                        "Comment",
                    },
                },
            },
            Ui.When(has_failed, function()
                return Indent { Indent { TailedOutput(server) } }
            end),
            Ui.When(
                server.uninstaller.error,
                Indent {
                    Ui.HlTextNode { server.uninstaller.error, "Comment" },
                }
            ),
        }
    end, servers))
end

local function UninstalledServers(servers)
    return Ui.Node(Data.list_map(function(server)
        return Ui.Node {
            Ui.HlTextNode {
                {
                    { settings.current.ui.icons.server_uninstalled, "LspInstallerMuted" },
                    { " " .. server.name, "Comment" },
                    { server.uninstaller.has_run and " (just uninstalled)" or "", "Comment" },
                },
            },
            Ui.Keybind(settings.current.ui.keymaps.toggle_server_expand, "EXPAND_SERVER", { server.name }),
            Ui.Keybind(settings.current.ui.keymaps.install_server, "INSTALL_SERVER", { server.name }),
            Ui.When(server.is_expanded, function()
                return Indent {
                    ServerMetadata(server),
                }
            end),
        }
    end, servers))
end

local function ServerGroup(props)
    local total_server_count = 0
    local chunks = props.servers
    for i = 1, #chunks do
        local servers = chunks[i]
        total_server_count = total_server_count + #servers
    end

    return Ui.When(total_server_count > 0 or not props.hide_when_empty, function()
        return Ui.Node {
            Ui.EmptyLine(),
            ServerGroupHeading {
                title = props.title,
                count = total_server_count,
            },
            Indent(Data.list_map(function(servers)
                return props.renderer(servers)
            end, props.servers)),
        }
    end)
end

local function Servers(servers)
    local grouped_servers = {
        installed = {},
        queued = {},
        session_installed = {},
        uninstall_failed = {},
        installing = {},
        install_failed = {},
        uninstalled = {},
        session_uninstalled = {},
    }

    -- giggity
    for _, server in pairs(servers) do
        if server.installer.is_running then
            grouped_servers.installing[#grouped_servers.installing + 1] = server
        elseif server.installer.is_queued then
            grouped_servers.queued[#grouped_servers.queued + 1] = server
        elseif server.uninstaller.has_run then
            if server.uninstaller.error then
                grouped_servers.uninstall_failed[#grouped_servers.uninstall_failed + 1] = server
            else
                grouped_servers.session_uninstalled[#grouped_servers.session_uninstalled + 1] = server
            end
        elseif server.is_installed then
            if server.installer.has_run then
                grouped_servers.session_installed[#grouped_servers.session_installed + 1] = server
            else
                grouped_servers.installed[#grouped_servers.installed + 1] = server
            end
        elseif server.installer.has_run then
            grouped_servers.install_failed[#grouped_servers.install_failed + 1] = server
        else
            grouped_servers.uninstalled[#grouped_servers.uninstalled + 1] = server
        end
    end

    return Ui.Node {
        ServerGroup {
            title = "Installed servers",
            renderer = InstalledServers,
            servers = { grouped_servers.session_installed, grouped_servers.installed },
        },
        ServerGroup {
            title = "Pending servers",
            hide_when_empty = true,
            renderer = PendingServers,
            servers = {
                grouped_servers.installing,
                grouped_servers.queued,
                grouped_servers.install_failed,
                grouped_servers.uninstall_failed,
            },
        },
        ServerGroup {
            title = "Available servers",
            renderer = UninstalledServers,
            servers = { grouped_servers.session_uninstalled, grouped_servers.uninstalled },
        },
    }
end

local function create_initial_server_state(server)
    return {
        name = server.name,
        is_installed = server:is_installed(),
        is_expanded = false,
        metadata = {
            homepage = server.homepage,
            install_timestamp_seconds = nil, -- lazy
            install_dir = server.root_dir,
        },
        installer = {
            is_queued = false,
            is_running = false,
            has_run = false,
            tailed_output = { "" },
        },
        uninstaller = { has_run = false, error = nil },
    }
end

local function normalize_chunks_line_endings(chunk, dest)
    local chunk_lines = vim.split(chunk, "\n")
    dest[#dest] = dest[#dest] .. chunk_lines[1]
    for i = 2, #chunk_lines do
        dest[#dest + 1] = chunk_lines[i]
    end
end

local function init(all_servers)
    local window = display.new_view_only_win "LSP servers"

    window.view(function(state)
        return Indent {
            Ui.Keybind(HELP_KEYMAP, "TOGGLE_HELP", nil, true),
            Ui.Keybind(CLOSE_WINDOW_KEYMAP_1, "CLOSE_WINDOW", nil, true),
            Ui.Keybind(CLOSE_WINDOW_KEYMAP_2, "CLOSE_WINDOW", nil, true),
            Header(),
            Ui.When(state.is_showing_help, function()
                return Help()
            end),
            Ui.When(not state.is_showing_help, function()
                return Servers(state.servers)
            end),
        }
    end)

    local servers = {}
    for i = 1, #all_servers do
        local server = all_servers[i]
        servers[server.name] = create_initial_server_state(server)
    end

    local mutate_state, get_state = window.init {
        servers = servers,
        is_showing_help = false,
    }

    -- TODO: memoize or throttle.. or cache. Do something. Also, as opposed to what the naming currently suggests, this
    -- is not really doing anything async stuff, but will very likely do so in the future :tm:.
    local function async_populate_server_metadata(server_name)
        local ok, server = lsp_servers.get_server(server_name)
        if not ok then
            return log.warn("Unable to get server when populating metadata.", server_name)
        end
        local fstat_ok, fstat = pcall(fs.fstat, server.root_dir)
        mutate_state(function(state)
            if fstat_ok then
                state.servers[server.name].metadata.install_timestamp_seconds = fstat.mtime.sec
            end
        end)
    end

    local function expand_server(server_name)
        mutate_state(function(state)
            state.servers[server_name].is_expanded = not state.servers[server_name].is_expanded
        end)
        async_populate_server_metadata(server_name)
    end

    local function start_install(server_tuple, on_complete)
        local server, requested_version = unpack(server_tuple)
        mutate_state(function(state)
            state.servers[server.name].installer.is_queued = false
            state.servers[server.name].installer.is_running = true
        end)

        log.fmt_info("Starting install server_name=%s, requested_version=%s", server.name, requested_version or "N/A")

        server:install_attached({
            requested_server_version = requested_version,
            stdio_sink = {
                stdout = function(chunk)
                    mutate_state(function(state)
                        local tailed_output = state.servers[server.name].installer.tailed_output
                        normalize_chunks_line_endings(chunk, tailed_output)
                    end)
                end,
                stderr = function(chunk)
                    mutate_state(function(state)
                        local tailed_output = state.servers[server.name].installer.tailed_output
                        normalize_chunks_line_endings(chunk, tailed_output)
                    end)
                end,
            },
        }, function(success)
            log.fmt_info("Installation completed server_name=%s, success=%s", server.name, success)
            mutate_state(function(state)
                if success then
                    -- release stdout/err output table.. hopefully ¯\_(ツ)_/¯
                    state.servers[server.name].installer.tailed_output = {}
                end
                state.servers[server.name].is_installed = success
                state.servers[server.name].is_expanded = true
                state.servers[server.name].installer.is_running = false
                state.servers[server.name].installer.has_run = true
            end)
            expand_server(server.name)
            on_complete()
        end)
    end

    -- We have a queue because installers have a tendency to hog resources.
    local queue
    do
        local max_running = settings.current.max_concurrent_installers
        local q = {}
        local r = 0

        local check_queue
        check_queue = vim.schedule_wrap(function()
            if #q > 0 and r < max_running then
                local dequeued_server = table.remove(q, 1)
                r = r + 1
                start_install(dequeued_server, function()
                    r = r - 1
                    check_queue()
                end)
            end
        end)

        queue = function(server, version)
            q[#q + 1] = { server, version }
            check_queue()
        end
    end

    local function install_server(server, version)
        log.debug("Installing server", server, version)
        local server_state = get_state().servers[server.name]
        if server_state and (server_state.installer.is_running or server_state.installer.is_queued) then
            log.debug("Installer is already queued/running", server.name)
            return
        end
        mutate_state(function(state)
            -- reset state
            state.servers[server.name] = create_initial_server_state(server)
            state.servers[server.name].installer.is_queued = true
        end)
        queue(server, version)
    end

    local function uninstall_server(server)
        local server_state = get_state().servers[server.name]
        if server_state and (server_state.installer.is_running or server_state.installer.is_queued) then
            log.debug("Installer is already queued/running", server.name)
            return
        end

        local is_uninstalled, err = pcall(server.uninstall, server)
        mutate_state(function(state)
            -- reset state
            state.servers[server.name] = create_initial_server_state(server)
            if is_uninstalled then
                state.servers[server.name].is_installed = false
            end
            state.servers[server.name].uninstaller.has_run = true
            state.servers[server.name].uninstaller.error = err
        end)
    end

    local function open()
        window.open {
            win_width = 95,
            highlight_groups = {
                "hi def LspInstallerHeader gui=bold guifg=#ebcb8b",
                "hi def LspInstallerServerExpanded gui=italic",
                "hi def LspInstallerHeading gui=bold",
                "hi def LspInstallerGreen guifg=#a3be8c",
                "hi def LspInstallerOrange ctermfg=222 guifg=#ebcb8b",
                "hi def LspInstallerMuted guifg=#888888 ctermfg=144",
                "hi def LspInstallerLabel gui=bold",
                "hi def LspInstallerError ctermfg=203 guifg=#f44747",
                "hi def LspInstallerHighlighted guifg=#56B6C2",
            },
            effects = {
                ["TOGGLE_HELP"] = function()
                    mutate_state(function(state)
                        state.is_showing_help = not state.is_showing_help
                    end)
                end,
                ["CLOSE_WINDOW"] = function()
                    window.close()
                end,
                ["EXPAND_SERVER"] = function(e)
                    local server_name = e.payload[1]
                    expand_server(server_name)
                end,
                ["INSTALL_SERVER"] = function(e)
                    local server_name = e.payload[1]
                    local ok, server = lsp_servers.get_server(server_name)
                    if ok then
                        install_server(server, nil)
                    end
                end,
                ["UNINSTALL_SERVER"] = function(e)
                    local server_name = e.payload[1]
                    local ok, server = lsp_servers.get_server(server_name)
                    if ok then
                        uninstall_server(server)
                    end
                end,
            },
        }
    end

    return {
        open = open,
        install_server = install_server,
        uninstall_server = uninstall_server,
    }
end

local win
return function()
    if win then
        return win
    end
    win = init(lsp_servers.get_available_servers())
    return win
end
