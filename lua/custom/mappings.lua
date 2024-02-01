---- If a keybind does not work, check ----
-- 1. Is a leading colon added?
-------------------------------------------

---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["q;"] = { "q:", "open command-line window", opts = { nowait = true } },

    --  format with conform
    ["<leader>fm"] = {
      function()
        require("conform").format()
      end,
      "formatting",
    },
    -- https://github.com/m-demare/attempt.nvim/#keymaps
    -- ["<leader>an"] = { function() require("attempt").new_select() end },
    ["<leader>an"] = { function() require("attempt").new_input_ext() end },
    -- ["<leader>ai"] = { function() require("attempt").new_input_ext() end },
    ["<leader>ar"] = { function() require("attempt").rename_buf() end },
    --["<leader>ar"] = { function() require("attempt").run() end },
    ["<leader>ad"] = { function() require("attempt").delete_buf() end },
    --["<leader>ac"] = { function() require("attempt").rename_buf() end },
    ["<leader>al"] = { ":Telescope attempt<CR>" },
    ["<leader>pq"] = { ':let @+ = \'"\' . expand("%:p") . \'"\'<CR>', "(p)ath with double (q)uotes:" },
    ["<Tab><Tab>"] = { ":Telescope buffers<CR>" },
    ["<leader>x"] = { ":bd<CR>", "close the current buffer" }
  },
  v = {
    [">"] = { ">gv", "indent"},
  },
  t = {
    ["<Esc>"] = { vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, true, true), "Escape terminal mode" },
  }
}

-- more keybinds!

return M
