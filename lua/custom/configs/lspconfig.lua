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

local trim = function(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

local ra_path = "C:/Users/User/.cargo/bin/ra-multiplex.exe"
local ra = io.open(".ra-multiplex.lspconfig", "rb")
if ra ~= nil then
  ra_path = trim(ra:read("*all"))
  vim.print(ra_path)
  ra:close()
end

for lsp, config in pairs({
  rust_analyzer = {
    cmd = { ra_path },
  },
  grammarly = {
    settings = {
      ["grammarly"] = {
        config = {
          ["documentDialect"] = "british",
          ["documentDomain"] = "academic",
        },
        ["suggestionCategories"] = {
          vocabulary = "off",
        },
      },
    },
  },
  gdscript = {
    root_dir = function (path)
      -- I fking hate how the path parameter does not point to the working directory.
      return vim.fs.dirname(vim.fs.find("project.godot", { path = vim.fn.getcwd() })[1])
    end,
    cmd = { "ncat", "localhost", "6005" }
  }
}) do
  config.on_attach = on_attach
  config.capabilities = capabilities
  lspconfig[lsp].setup(config)
end
--
-- lspconfig.pyright.setup { blabla}
