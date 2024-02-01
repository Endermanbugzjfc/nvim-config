local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

-- if you just want default config for the servers then put them in a table
local servers = { "html", "cssls", "tsserver", "clangd", "intelephense", "gopls" }

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

lspconfig.rust_analyzer.setup{
  on_attach = on_attach,
  capabilities = capabilities,
  ["rust-analyzer"] = {
    ["server"] = {
      ["path"] = "C:/Users/User/.cargo/bin/ra-multiplex.exe",
    },
  },
}

-- 
-- lspconfig.pyright.setup { blabla}
