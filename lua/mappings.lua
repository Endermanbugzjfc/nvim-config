require "nvchad.mappings"
local map = vim.keymap.set

-- https://github.com/m-demare/attempt.nvim/#keymaps
local attempt = require("attempt")
map("n", "<leader>an", attempt.new_input_ext, { desc = "New scratch file with extension name"})
map("n", "<leader>ar", attempt.rename_buf, { desc = "Rename scratch file" })
map("n", "<leader>ad", attempt.delete_buf, { desc = "Delete scratch file" })
map("n", "<leader>al", ":Telescope attempt<CR>", { desc = "List scratch files" })

-- https://github.com/Bekaboo/dropbar.nvim?tab=readme-ov-file#installation
local dropbar = require('dropbar.api')
vim.keymap.set('n', '<Leader>;', dropbar.pick, { desc = 'Pick symbols in winbar' })
vim.keymap.set('n', '[;', dropbar.goto_context_start, { desc = 'Go to start of current context' })
vim.keymap.set('n', '];', dropbar.select_next_context, { desc = 'Select next context' })

-- DERIVED --

map("n", "<leader>fr", ":Telescope resume<CR>", { desc = "Resume last Telescope picker" })
-- map("n", "gr", ":Telescope lsp_references<CR>", { desc = "Goto references" })
-- map("n", "gd", ":Telescope lsp_definitions<CR>", { desc = "Goto definitions" })

map("n", "<Leader>o", ":Oil<CR>")
map(
  "n",
  "<A-h>",
  function()
    vim.cmd("silent! :NvimTreeClose")
    require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
  end,
  { desc = "Toggle horizontal term" }
)
map("n", "<leader>l", require("mini.map").toggle_focus, { desc = "Focus mini map" })

-- MISCELLANEOUS --

map("n", "<leader>pq", ':let @+ = \'"\' . expand("%:p") . \'"\'<CR>', { desc = "Path with double (q)uotes" })
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
map("v", ">", ">gv", { desc = "indent"})
map("n", "<C-x>", "<C-w><C-q>")
