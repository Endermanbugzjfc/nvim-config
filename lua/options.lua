require "nvchad.options"

vim.o.clipboard = ""
vim.o.mouse = ""
vim.o.foldmethod = "marker"
vim.g.lua_snippets_path = vim.fn.stdpath "config" .. "/lua/lua_snippets"

-- Automatically `cd` to last argument:
vim.o.autochdir = true
vim.schedule(function()
  vim.o.autochdir = false
end)

