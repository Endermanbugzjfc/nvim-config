require("nvchad.configs.lspconfig").defaults()

vim.lsp.config("jdtls", require("after.lsp.jdtls"))

local servers = {
  "nil_ls",
  "eslint",

  "html",
  "jdtls",
  "cssls",

  "ts_ls",
}
vim.lsp.enable(servers)


-- read :h vim.lsp.config for changing options of lsp servers

-- lspconfig["grammarly"].setup {
--   on_attach = nvlsp.on_attach,
--   on_init = nvlsp.on_init,
--   capabilities = nvlsp.capabilities,
--   settings = { grammarly = {
--     config = {
--       documentDialect = "british",
--       documentDomain = "academic",
--     },
--     suggestionCategories = { vocabulary = "off" },
--   } },
-- }
