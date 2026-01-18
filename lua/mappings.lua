require "nvchad.mappings"
local map = vim.keymap.set

-- {{{ PLUGINS

-- https://github.com/m-demare/attempt.nvim/#keymaps
local attempt = require("attempt")
map("n", "<leader>an", attempt.new_input_ext, { desc = "New scratch file with extension name"})
map("n", "<leader>ar", attempt.rename_buf, { desc = "Rename scratch file" })
map("n", "<leader>ad", attempt.delete_buf, { desc = "Delete scratch file" })
map("n", "<leader>al", ":Telescope attempt<CR>", { desc = "List scratch files" })

-- https://github.com/Bekaboo/dropbar.nvim?tab=readme-ov-file#installation
local dropbar = require('dropbar.api')
map('n', '<Leader>;', dropbar.pick, { desc = 'Pick symbols in winbar' })
map('n', '[;', dropbar.goto_context_start, { desc = 'Go to start of current context' })
map('n', '];', dropbar.select_next_context, { desc = 'Select next context' })

map("n", "<Leader>dep", function()
  require("dapui").eval(vim.fn.getreg('"'))
end, { desc = "Evaluate yanked expression in debugger" })
local persistent = require("persistent-breakpoints.api")
map("n", "<Leader>dd", persistent.toggle_breakpoint, { desc = "Toggle breakpoint" })
map("n", "<Leader>dc", persistent.set_conditional_breakpoint, { desc = "Set conditional breakpoint" })
map("n", "<Leader>d!", persistent.clear_all_breakpoints, { desc = "Clear all breakpoints" })
map("n", "<Leader>dl", persistent.set_log_point, { desc = "Set log point" })

map("n", "<Leader>o", function()
  local mini_files = require("mini.files")
  mini_files.open(vim.api.nvim_buf_get_name(0))
end, { desc = "Open Mini.Files" })

local mini_map = require("mini.map")
map("n", "<leader>l", function()
  mini_map.open()
  mini_map.toggle_focus()
end, { desc = "Focus mini map" })
map("n", "<leader>L", function()
  mini_map.close()
end)

-- }}}

-- {{{ FEATURES

map("n", "<leader>fr", ":Telescope resume<CR>", { desc = "Resume last Telescope picker" })
-- map("n", "gr", ":Telescope lsp_references<CR>", { desc = "LSP references" })
map("n", "gd", ":Telescope lsp_definitions<CR>", { desc = "LSP definitions" })

map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP code action" })

map("n", "<leader>pq", ':let @+ = \'"\' . expand("%:p") . \'"\'<CR>', { desc = "Copy path with double (q)uotes" })
map("n", "<leader>pr", ':let @+ = expand("%:p")<CR>', { desc = "Copy path (r)aw" })
map("n", "<leader>pQ", ':let @+ = expand("%:p:h")<CR>', { desc = "Copy parent path with double (q)uotes" })
map("n", "<leader>pR", ':let @+ = expand("%:p")<CR>', { desc = "Copy parent path (r)aw" })

  -- ["<leader>tc"] = {
  --   function()
  --     if CmpSuspendRelease ~= nil then
  --       CmpSuspendRelease()
  --       CmpSuspendRelease = nil
  --       vim.g.cmp_suspend_release = false
  --       return
  --     end
  --
  --     vim.g.cmp_suspend_release = true
  --     CmpSuspendRelease = require("cmp").suspend()
  --   end,
  --   "Toggle completion"
  -- },
-- Always close NvimTree before opening the horizontal terminal:

map("n", "|", "<C-w>+", { desc = "Increase panel height" })
map("n", "\\", "<C-w>>", { desc = "Increase panel width" })

map("n", "<leader>zm", function()
  if vim.o.foldmethod ~= "marker" then
    vim.o.foldmethod = "marker"
  else
    vim.o.foldmethod = "indent"
  end
  vim.cmd("set foldmethod")
end, { desc = "Cycle foldmethod between marker and indent" })
-- TODO: toggle wrap text

local base64 = require("base46")
map("n", "<leader>tt", base64.toggle_theme, { desc = "Toggle theme" })
map("n", "<leader>tb", base64.toggle_transparency, { desc = "Toggle transparency" })

map("n", "<leader>Bm", ":new<CR>:put =execute('messages')<CR>", { desc = "Show Nvim messages (in buffer)" })

-- }}}

-- {{{ WORKAROUNDS
map("v", ">", ">gv", { desc = "indent increase (improved)"})
map("v", "<", "<gv", { desc = "indent decrease (improved)"})

map("v", "u", "", { desc = "Unmapped (previously converts selection to lowercase)" });
map("v", "<leader>uu", "u", { desc = "Converts selection to lowercase" })

map("n", "<C-n>", "", { desc = "Unmapped (previously opens NvimTree)" })
-- }}}
