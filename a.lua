require("nvim-lsp-installer").setup {
  ui = {
    icons = {
      server_installed = "",
      server_pending = "",
      server_uninstalled = "",
    },
  },
}
local lspconfig = require("lspconfig")

local function on_attach(client, bufnr)
  -- set up buffer keymaps, etc.
end

local rust_tools = require("rust-tools")
rust_tools.setup {
    server = { on_attach = on_attach }
}

local tsutils = require "nvim-lsp-ts-utils"
lspconfig.tsserver.setup {
  init_options = { hostInfo = "neovim" },
  on_attach = function (client, bufnr)
    tsutils.setup {}
    tsutils.setup_client(client)
  end
}

lspconfig.sumneko_lua.setup {
  on_attach = on_attach,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" }
      }
    }
  }
}

lspconfig.graphql.setup { on_attach = on_attach }
lspconfig.jsonls.setup { on_attach = on_attach }
lspconfig.cssls.setup { on_attach = on_attach }
