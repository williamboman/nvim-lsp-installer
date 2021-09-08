local dispatcher = require "nvim-lsp-installer.dispatcher"
local fs = require "nvim-lsp-installer.fs"
local path = require "nvim-lsp-installer.path"
local status_win = require "nvim-lsp-installer.ui.status-win"

local M = {}

function M.get_server_root_path(server)
    return path.concat { path.SERVERS_ROOT_DIR, server }
end

M.Server = {}
M.Server.__index = M.Server

---@class Server
--@param opts table
-- @field name (string)                  The name of the LSP server. This MUST correspond with lspconfig's naming.
--
-- @field root_dir (string)              The root directory of the installation. Most servers will make use of server.get_server_root_path() to produce its root_dir path.
--
-- @field installer (function)           The function that installs the LSP (see the .installers module). The function signature should be `function (server, callback)`, where
--                                       `server` is the Server instance being installed, and `callback` is a function that must be called upon completion. The `callback` function
--                                       has the signature `function (success, result)`, where `success` is a boolean and `result` is of any type (similar to `pcall`).
--
-- @field default_options (table)        The default options to be passed to lspconfig's .setup() function. Each server should provide at least the `cmd` field.
--
-- @field pre_install_check (function)   An optional function to be executed before the installer. This allows ensuring that any prerequisites are fulfilled.
--                                       This could for example be verifying that required build tools are installed.
--
-- @field post_setup (function)          An optional function to be executed after the setup function has been successfully called.
--                                       Use this to defer setting up server specific things until they're actually
--                                       needed, like custom commands.
--
-- @field pre_setup (function)           An optional function to be executed prior to calling lspconfig's setup().
--                                       Use this to defer setting up server specific things until they're actually needed.
--
function M.Server:new(opts)
    return setmetatable({
        name = opts.name,
        root_dir = opts.root_dir,
        _root_dir = opts.root_dir, -- @deprecated Use the `root_dir` property instead.
        _installer = opts.installer,
        _default_options = opts.default_options,
        _pre_install_check = opts.pre_install_check,
        _post_setup = opts.post_setup,
        _pre_setup = opts.pre_setup,
    }, M.Server)
end

function M.Server:setup(opts)
    if self._pre_setup then
        self._pre_setup()
    end
    -- We require the lspconfig server here in order to do it as late as possible.
    -- The reason for this is because once a lspconfig server has been imported, it's
    -- automatically registered with lspconfig and causes it to show up in :LspInfo and whatnot.
    require("lspconfig")[self.name].setup(vim.tbl_deep_extend("force", self._default_options, opts or {}))
    if self._post_setup then
        self._post_setup()
    end
end

function M.Server:get_default_options()
    return vim.deepcopy(self._default_options)
end

function M.Server:is_installed()
    return fs.dir_exists(self._root_dir)
end

function M.Server:create_root_dir()
    fs.mkdirp(self._root_dir)
end

function M.Server:install()
    status_win().install_server(self)
end

function M.Server:install_attached(opts, callback)
    local pre_install_ok, pre_install_err = pcall(self.pre_install, self)
    if not pre_install_ok then
        opts.stdio_sink.stderr(tostring(pre_install_err))
        callback(false)
        return
    end

    local install_ok, install_err = pcall(self._installer, self, function(success)
        if not success then
            pcall(self.uninstall, self)
        else
            vim.schedule(function()
                dispatcher.dispatch_server_ready(self)
            end)
        end
        callback(success)
    end, opts)
    if not install_ok then
        opts.stdio_sink.stderr(tostring(install_err))
        callback(false)
    end
end

function M.Server:pre_install()
    if self._pre_install_check then
        self._pre_install_check()
    end

    -- We run uninstall after pre_install_check because we don't want to
    -- unnecessarily uninstall a server should it no longer pass the
    -- pre_install_check.
    self:uninstall()

    self:create_root_dir()
end

function M.Server:uninstall()
    if fs.dir_exists(self._root_dir) then
        fs.rmrf(self._root_dir)
    end
end

return M
