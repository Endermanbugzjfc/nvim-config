-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
local lspconfig = require "lspconfig"

-- EXAMPLE
local servers = {
  "nil_ls",
  "eslint",

  "html",
  "cssls",
}
local nvlsp = require "nvchad.configs.lspconfig"

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

lspconfig["grammarly"].setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  settings = { grammarly = {
    config = {
      documentDialect = "british",
      documentDomain = "academic",
    },
    suggestionCategories = { vocabulary = "off" },
  } },
}

-- OPTIONAL LSP --


