local lsp_installer = require("nvim-lsp-installer")

lsp_installer.settings {
  ui = {
    icons = {
      server_installed = "",
      server_pending = "",
      server_uninstalled = "",
    },
  },
}

local function on_attach(client, bufnr)
  -- set up buffer keymaps, etc.
end

lsp_installer.on_server_ready(function (server)
  local opts = {
    on_attach = on_attach
  }

  if server.name == "tsserver" then
    local tsutils = require "nvim-lsp-ts-utils"
    opts.init_options = { hostInfo = "neovim" }
    opts.on_attach = function (client, bufnr)
      tsutils.setup {}
      tsutils.setup_client(client)
    end
  elseif server.name == "sumneko_lua" then
    opts.settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" }
        }
      }
    }
  end

  server:setup(opts)
end)
