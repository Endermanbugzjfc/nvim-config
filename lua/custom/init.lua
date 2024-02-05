-- local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })

local unix = vim.fn.has "unix" == 1

vim.opt.clipboard = ""
if not unix then
  --vim.opt.shell = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
  vim.opt.shell = "powershell"
  vim.opt.shellcmdflag = "-command"
  vim.opt.shellquote = '"'
  vim.opt.shellxquote = ""
end
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- https://nvchad.com/docs/config/snippets
vim.g.lua_snippets_path = vim.fn.stdpath "config" .. "/lua/custom/lua_snippets"
-- https://github.com/markonm/traces.vim/issues/41#issuecomment-774324994
vim.g.traces_abolish_integration = 1
