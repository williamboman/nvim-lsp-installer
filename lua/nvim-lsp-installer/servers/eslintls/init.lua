local lspconfig = require("lspconfig")
local configs = require("lspconfig/configs")

local server = require("nvim-lsp-installer.server")
local path = require("nvim-lsp-installer.path")
local shell = require("nvim-lsp-installer.installers.shell")

configs.eslintls = {
    default_config = {
        filetypes = {"javascript", "javascriptreact", "typescript", "typescriptreact"},
        root_dir = lspconfig.util.root_pattern(".eslintrc*", "package.json", ".git"),
        -- Refer to https://github.com/Microsoft/vscode-eslint#settings-options for documentation.
        settings = {
            validate = "on",
            run = "onType",
            codeAction = {
                disableRuleComment = {
                    enable = true,
                    -- "sameLine" might not work as expected, see https://github.com/williamboman/nvim-lsp-installer/issues/4
                    location = "separateLine"
                },
                showDocumentation = {
                    enable = true
                }
            },
            codeActionOnSave = {
                -- If not enabled, eslint LSP won't respond to "source.fixAll" requests
                enable = true
            },
            format = {
                -- If not enabled, eslint LSP won't respond to either 1) document formatting requests, or 2) "eslint.applyAllFixes" requests
                enable = true
            },
            rulesCustomizations = {},
            -- Automatically determine working directory by locating .eslintrc config files.
            --
            -- It's recommended not to change this.
            workingDirectory = {mode = "auto"},
            -- If nodePath is a non-null/undefined value the eslint LSP runs into runtime exceptions.
            --
            -- It's recommended not to change this.
            nodePath = "",
            -- The "workspaceFolder" is a VSCode concept. We set it to the root
            -- directory to not restrict the LPS server when it traverses the
            -- file tree when locating a .eslintrc config file.
            --
            -- It's recommended not to change this.
            workspaceFolder = {
                uri = "/",
                name = "root"
            }
        }
    }
}

local ConfirmExecutionResult = {
    deny = 1,
    confirmationPending = 2,
    confirmationCanceled = 3,
    approved = 4
}

local root_dir = server.get_server_root_path("eslint")
local install_cmd = [[
git clone --depth 1 https://github.com/microsoft/vscode-eslint .;
git fetch origin refs/pull/1307/head && git checkout FETCH_HEAD;
npm install;
cd server;
npm install;
../node_modules/.bin/tsc;
]]

return server.Server:new {
    name = "eslintls",
    root_dir = root_dir,
    installer = shell.raw(install_cmd),
    default_options = {
        cmd = { "node", path.concat { root_dir, "server", "out", "eslintServer.js" }, "--stdio" },
        handlers = {
            ["eslint/openDoc"] = function (_, _, open_doc)
                os.execute(string.format("open %q", open_doc.url))
                return {id = nil, result = true}
            end,
            ["eslint/confirmESLintExecution"] = function ()
                -- VSCode language servers have a policy to request explicit approval
                -- before applying code changes. We just approve it immediately.
                return ConfirmExecutionResult.approved
            end,
            ["eslint/probeFailed"] = function ()
                vim.api.nvim_err_writeln("ESLint probe failed.")
                return {id = nil, result = true}
            end,
            ["eslint/noLibrary"] = function ()
                vim.api.nvim_err_writeln("Unable to find ESLint library.")
                return {id = nil, result = true}
            end,
            ["eslint/noConfig"] = function ()
                vim.api.nvim_err_writeln("Unable to find ESLint configuration.")
                return {id = nil, result = true}
            end,
        },
    },
}
