---- If a keybind does not work, check ----
-- 1. Is a leading colon added?
-------------------------------------------

---@type MappingsTable
local M = {}
local CmpSuspendRelease = nil
vim.g.cmp_suspend_release = false

M.general = {
  n = {
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
    ["<leader>ad"] = { function() require("attempat").delete_buf() end, "Delete scratch file" },
    --["<leader>ac"] = { function() require("attempt").rename_buf() end },
    ["<leader>al"] = { ":Telescope attempt<CR>", "List scratch files" },

    -- ["<leader>fZ"] = { ":Telescope live_grep<CR>", "Live grep" }, -- (Use <leader>fw.)
    ["<leader>fr"] = { ":Telescope resume<CR>", "Resume last Telescope picker" },
    ["<leader>fq"] = { ":Telescope diagnostics<CR>", "Project / workspace level diagnostics" },
    ["<leader>fs"] = { ":Telescope lsp_document_symbols<CR>", "Document symbols" },
    ["<leader>pq"] = { ':let @+ = \'"\' . expand("%:p") . \'"\'<CR>', "Path with double (q)uotes" },
    ["<leader>x"] = { ":bd<CR>", "Close this buffer" },
    ["<leader>tw"] = { ":set wrap!<CR>", "Toggle word wrap" },
    ["<leader>tc"] = {
      function()
        if CmpSuspendRelease ~= nil then
          CmpSuspendRelease()
          CmpSuspendRelease = nil
          vim.g.cmp_suspend_release = false
          return
        end

        vim.g.cmp_suspend_release = true
        CmpSuspendRelease = require("cmp").suspend()
      end,
      "Toggle completion"
    },

    -- Imo location list only suits diagnostics:
    ["gr"] = { ":Telescope lsp_references<CR>", "Goto references" },
    ["gd"] = { ":Telescope lsp_definitions<CR>", "Goto definitions" },

    -- Always close NvimTree before opening the horizontal terminal:
    ["<A-h>"] = {
      function()
        vim.cmd("silent! :NvimTreeClose")
        require("nvterm.terminal").toggle "horizontal"
      end,
      "Toggle horizontal term",
    },

    -- https://github.com/lewis6991/gitsigns.nvim/blob/2c2463dbd82eddd7dbab881c3a62cfbfbe3c67ae/lua/gitsigns/actions.lua#L377
    ["<leader>gs"] = { function() require("gitsigns").stage_hunk() end, "Stage hunk" },
    ["<leader>gS"] = { function() require("gitsigns").undo_stage_hunk() end, "Undo last stage" },
  },
  v = {
    [">"] = { ">gv", "indent"},
    ["<leader>gs"] = { function() require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage lines" },
  },
  t = {
    ["<Esc>"] = { vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, true, true), "Escape terminal mode" },
  }
}


local function vn(k, v)
  M.general.n[k] = v
  M.general.v[k] = v
end
vn(";", { ":", "enter command mode", opts = { nowait = true } })
vn("q;", { "q:", "open command-line window", opts = { nowait = true } })

-- more keybinds!

    return M
