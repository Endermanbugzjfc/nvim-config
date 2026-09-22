require("nvchad.configs.lspconfig").defaults()

-- tsserver is a Node process; by default it caps its heap fairly low and slows
-- down on big projects. Give it 8G so it stops thrashing / restarting.
vim.lsp.config("ts_ls", {
  init_options = {
    maxTsServerMemory = 8192, -- MB
  },
})

local servers = {
  "nil_ls",
  "eslint",

  "html",
  "cssls",

  "ts_ls",
}

if vim.env.NVIM_ENABLE_JDTLS_DEBUGGER ~= "1" then
  vim.lsp.config("jdtls", require("after.lsp.jdtls"))
  servers[#servers + 1] = "jdtls"
end

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
