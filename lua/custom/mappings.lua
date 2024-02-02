---- If a keybind does not work, check ----
-- 1. Is a leading colon added?
-------------------------------------------

---@type MappingsTable
local M = {}
local generate_wrap_operations = function(left, right)
  -- return {"<Esc>`<i" .. left .. "<Esc>`>la" .. right .. "<Esc>gv2l", "wrap selection with" .. left .. right }
  return {"<Esc>`<i <Esc>r" .. left .. "<Esc>`>la" .. right .. "<Esc>gv2l", "wrap selection with" .. left .. right }
end

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["q;"] = { "q:", "open command-line window", opts = { nowait = true } },
    ["Y"] = { "yy" },

    --  format with conform
    ["<leader>fm"] = {
      function()
        require("conform").format()
      end,
      "Formatting",
    },
    -- https://github.com/m-demare/attempt.nvim/#keymaps
    -- ["<leader>an"] = { function() require("attempt").new_select() end },
    ["<leader>an"] = { function() require("attempt").new_input_ext() end, "New scratch file with extension name"},
    -- ["<leader>ai"] = { function() require("attempt").new_input_ext() end },
    ["<leader>ar"] = { function() require("attempt").rename_buf() end, "Rename scratch file" },
    --["<leader>ar"] = { function() require("attempt").run() end },
    ["<leader>ad"] = { function() require("attempt").delete_buf() end, "Delete scratch file" },
    --["<leader>ac"] = { function() require("attempt").rename_buf() end },
    ["<leader>al"] = { ":Telescope attempt<CR>", "List scratch files" },
    ["<leader>pq"] = { ':let @+ = \'"\' . expand("%:p") . \'"\'<CR>', "Path with double (q)uotes" },
    ["<leader>x"] = { ":bd<CR>", "Close this buffer" },

    -- Imo location list only suits diagnostics:
    ["gr"] = { ":Telescope lsp_references<CR>", "Goto references" },
    ["gd"] = { ":Telescope lsp_definitions<CR>", "Goto definitions" },
  },
  v = {
    -- https://github.com/jiangmiao/auto-pairs
    [">"] = { ">gv", "indent"},
    ["<leader>("] = generate_wrap_operations("(", ")"),
    ["<leader>{"] = generate_wrap_operations("{", "}"),
    ["<leader><"] = generate_wrap_operations("<", ">"),
    ['<leader>"'] = generate_wrap_operations('"', '"'),
    ["<leader>'"] = generate_wrap_operations("'", "'"),
    ["<leader>["] = generate_wrap_operations("[", "]"),
  },
  t = {
    ["<Esc>"] = { vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, true, true), "Escape terminal mode" },
  }
}

-- more keybinds!

return M
