local on_windows = vim.loop.os_uname().version:match "Windows"

local function join_paths(...)
    local path_sep = on_windows and "\\" or "/"
    local result = table.concat({ ... }, path_sep)
    return result
end

vim.cmd [[set runtimepath=$VIMRUNTIME]]

local temp_dir = vim.loop.os_getenv "TEMP" or "/tmp"

vim.cmd("set packpath=" .. join_paths(temp_dir, "nvim", "site"))

local package_root = join_paths(temp_dir, "nvim", "site", "pack")
local install_path = join_paths(package_root, "packer", "start", "packer.nvim")
local compile_path = join_paths(install_path, "plugin", "packer_compiled.lua")

local function load_plugins()
    require("packer").startup {
        {
            "wbthomason/packer.nvim",
            "neovim/nvim-lspconfig",
            "williamboman/nvim-lsp-installer",
        },
        config = {
            package_root = package_root,
            compile_path = compile_path,
        },
    }
end

_G.load_config = function()
    vim.lsp.set_log_level "trace"
    require("vim.lsp.log").set_format_func(vim.inspect)
    local on_attach = function(_, bufnr)
        local function buf_set_keymap(...)
            vim.api.nvim_buf_set_keymap(bufnr, ...)
        end
        local function buf_set_option(...)
            vim.api.nvim_buf_set_option(bufnr, ...)
        end

        buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

        -- Mappings.
        local opts = { noremap = true, silent = true }
        buf_set_keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
        buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
        buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
        buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
        buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
        buf_set_keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
        buf_set_keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
        buf_set_keymap("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
        buf_set_keymap("n", "<space>lD", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
        buf_set_keymap("n", "<space>lr", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
        buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
        buf_set_keymap("n", "gl", "<cmd>lua vim.diagnostic.open_float(0,{scope='line'})<CR>", opts)
        buf_set_keymap("n", "<space>lk", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
        buf_set_keymap("n", "<space>lj", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
        buf_set_keymap("n", "<space>lq", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
        buf_set_keymap("n", "<space>li", "<cmd>LspInfo<CR>", opts)
        buf_set_keymap("n", "<space>lI", "<cmd>LspInstallInfo<CR>", opts)
        buf_set_keymap("n", "<space>Ll", "<cmd>lua vim.fn.execute('edit ' .. vim.lsp.get_log_path())<CR>", opts)
        buf_set_keymap("n", "<space>LL", "<cmd>LspInstallLog<CR>", opts)
    end

    -- Add the server that troubles you here, e.g. "sumneko_lua", "pyright", "tsserver"
    local name = "sumneko_lua"
    print("Setting up " .. name .. "server")

    -- Change the default settings
    require("nvim-lsp-installer").settings {
        log = "debug",
        -- install_root_dir = vim.fn.stdpath "data" .. "/lsp_servers",
    }

    local server_available, requested_server = require("nvim-lsp-installer.servers").get_server(name)
    if not server_available then
        error "The requested server isn't available. Please check the specificed name is correct in minimal_init.lua"
        return
    end

    if not requested_server:is_installed() then
        requested_server:install_sync()
    end

    requested_server:on_ready(function()
        requested_server:setup { on_attach = on_attach }
    end)

    print(
        "You can find the lsp logfile at "
            .. vim.lsp.get_log_path()
            .. ", and the installer logfile at"
            .. require("nvim-lsp-installer.log").outfile
            .. ". Please paste it in a github issue as described in the issue template"
    )
end

if vim.fn.isdirectory(install_path) == 0 then
    vim.fn.system { "git", "clone", "https://github.com/wbthomason/packer.nvim", install_path }
    load_plugins()
    require("packer").sync()
    vim.cmd [[autocmd User PackerComplete ++once lua load_config()]]
else
    load_plugins()
    require("packer").sync()
    _G.load_config()
end
