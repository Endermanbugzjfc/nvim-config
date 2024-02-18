-- local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })

local unix = vim.fn.has "unix" == 1

-- https://github.com/f40a3204/nvim/blob/cbb8c3cac259e26f5c77cb223087fb0a3ab9d36b/init.lua#L10-L13
vim.api.nvim_exec([[
  au BufEnter * setlocal cursorline
  au BufLeave * setlocal nocursorline
]], false) -- https://github.com/SOF3/nvim-config/blob/0cecba2a63712f33755befe3fe3d2518a64cffd0/config/init.vim#L10

-- https://github.com/SOF3/nvim-config/blob/0cecba2a63712f33755befe3fe3d2518a64cffd0/config/init.vim#L23
vim.opt.autoread = true
vim.opt.autowrite = true

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
vim.opt.rnu = true
-- vim.opt.spell = true -- Useless and wastes mapping slots.
-- vim.opt.spelllang = "en_gb"

-- https://nvchad.com/docs/config/snippets
vim.g.lua_snippets_path = vim.fn.stdpath "config" .. "/lua/custom/lua_snippets"
-- https://github.com/markonm/traces.vim/issues/41#issuecomment-774324994
vim.g.traces_abolish_integration = 1
