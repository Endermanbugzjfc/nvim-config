---- If a keybind does not work, check ----
-- 1. Is a leading colon added?
-------------------------------------------

---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },

    --  format with conform
    ["<leader>fm"] = {
      function()
        require("conform").format()
      end,
      "formatting",
    },
    -- https://github.com/m-demare/attempt.nvim/#keymaps
    ["<leader>an"] = { function() require("attempt").new_select() end },
    ["<leader>ai"] = { function() require("attempt").new_input_ext() end },
    ["<leader>ar"] = { function() require("attempt").rename_buf() end },
    --["<leader>ar"] = { function() require("attempt").run() end },
    ["<leader>ad"] = { function() require("attempt").delete_buf() end },
    --["<leader>ac"] = { function() require("attempt").rename_buf() end },
    ["<leader>al"] = { ":Telescope attempt<CR>" },

    -- (p)ath with double (q)uotes:
    ["<leader>pq"] = { ':let @+ = \'"\' . expand("%:p") . \'"\'<CR>' }
  },
  v = {
    [">"] = { ">gv", "indent"},
  },
}

-- more keybinds!
--or: map('n', '<leader>al', attempt.open_select) -- use ui.select instead of telescope

return M
