local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

-- if you just want default config for the servers then put them in a table
local servers = { "html", "cssls", "tsserver", "clangd", "intelephense", "gopls", "vimls" }

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

for lsp, config in pairs({
  rust_analyzer = {
    ["rust-analyzer"] = {
      server = {
        path = "C:/Users/User/.cargo/bin/ra-multiplex.exe",
      },
    },
  },
  -- grammarly = {
  --   grammarly = {
  --     config = { -- TODO: try client ID
  --       ["documentDialect"] = "british",
  --       ["documentDomain"] = "academic",
  --     },
  --     ["suggestionCategories"] = {
  --       vocabulary = "off",
  --     },
  --   },
  -- },
}) do
  config.on_attach = on_attach
  config.capabilities = capabilities
  lspconfig[lsp].setup(config)
end
--
-- lspconfig.pyright.setup { blabla}
