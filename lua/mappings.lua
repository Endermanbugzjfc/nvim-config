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
map("n", "<leader>tg", base64.toggle_theme, { desc = "Toggle theme" })
map("n", "<leader>ty", base64.toggle_transparency, { desc = "Toggle transparency" })

map("n", "<leader>Bm", ":new<CR>:put =execute('messages')<CR>", { desc = "Show Nvim messages (in buffer)" })

-- Move current buffer tab forward / backward in the bufferline
map("n", "-", function()
  local bufs = vim.t.bufs
  local cur = vim.api.nvim_get_current_buf()

  for i, buf in ipairs(bufs) do
    if buf == cur then
      if i == #bufs then
        -- Rotate: pull from end, insert at beginning
        table.remove(bufs, i)
        table.insert(bufs, 1, cur)
        vim.t.bufs = bufs
        vim.cmd("redrawtabline")
      else
        require("nvchad.tabufline").move_buf(1)
      end
      break
    end
  end
end, { desc = "Buffer move forward" })

map("n", "_", function()
  local bufs = vim.t.bufs
  local cur = vim.api.nvim_get_current_buf()

  for i, buf in ipairs(bufs) do
    if buf == cur then
      if i == 1 then
        -- Rotate: pull from beginning, insert at end
        table.remove(bufs, i)
        table.insert(bufs, cur)
        vim.t.bufs = bufs
        vim.cmd("redrawtabline")
      else
        require("nvchad.tabufline").move_buf(-1)
      end
      break
    end
  end
end, { desc = "Buffer move backward" })

-- Copy current line to system clipboard
map("n", "+", 'V"+y', { desc = "Copy current line to system clipboard" })
map("v", "+", '"+y', { desc = "Copy selection to system clipboard" })

-- Close other tabs
map("n", "<leader>X", function()
  local cur = vim.api.nvim_get_current_buf()
  local bufs = vim.t.bufs

  local cur_index = 1
  for i, buf in ipairs(bufs) do
    if buf == cur then
      cur_index = i
      break
    end
  end

  -- Hide all buffers to the right
  for i = cur_index + 1, #bufs do
    vim.bo[bufs[i]].buflisted = false
  end

  -- Trim the tabufline to everything up to and including current
  vim.t.bufs = { unpack(bufs, 1, cur_index) }
  vim.cmd("redrawtabline")
end, { desc = "Close buffers to the right" })

map("n", "<C-x>", "<C-w>q", { desc = "Close pane" })

-- }}}

-- {{{ WORKAROUNDS
map("v", ">", ">gv", { desc = "indent increase (improved)"})
map("v", "<", "<gv", { desc = "indent decrease (improved)"})

map("v", "u", "", { desc = "Unmapped (previously converts selection to lowercase)" });
map("v", "<leader>uu", "u", { desc = "Converts selection to lowercase" })

-- map("n", "<C-n>", "", { desc = "Unmapped (previously opens NvimTree)" })
map("n", "<leader>h", "", { desc = "Unmapped (previously terminal new horizontal term)" })

-- <C-i> and <Tab> have the same terminal keycode and <Tab> is next tab
map("n", "<C-n>", "<Esc>1\t<CR>", { desc = "jumplist forward" })

-- Hide instead of deleting buffer:
map("n", "<leader>x", function()
  local cur = vim.api.nvim_get_current_buf()
  local bufs = vim.t.bufs

  for i, buf in ipairs(bufs) do
    if buf == cur then
      table.remove(bufs, i)

      -- Switch to an adjacent buffer before hiding
      if #bufs > 0 then
        vim.api.nvim_set_current_buf(bufs[math.min(i, #bufs)])
      end
      break
    end
  end

  vim.t.bufs = bufs
  vim.cmd("redrawtabline")

  -- Hide from tabufline/bufferlist but DO NOT delete — preserves jumplist
  vim.bo[cur].buflisted = false
end, { desc = "Close buffer" })

-- Alt + tab number:
for i = 1, 9 do
  map("n", "<A-" .. i .. ">", function()
    local bufs = vim.t.bufs
    if bufs[i] then
      vim.api.nvim_set_current_buf(bufs[i])
    end
  end, { desc = "Go to buffer " .. i })
end

map("n", "<A-0>", function()
  local bufs = vim.t.bufs
  vim.api.nvim_set_current_buf(bufs[#bufs])
end, { desc = "Go to last buffer" })

-- }}}
