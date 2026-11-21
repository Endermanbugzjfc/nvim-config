local M = {}
local selections = {}

local function switch(move)
  local win, buf = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
  selections[win] = selections[win] or {}
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    selections[win][buf] = {
      mode = mode,
      anchor = vim.fn.getpos("v"),
      cursor = vim.fn.getpos("."),
      view = vim.fn.winsaveview(),
    }
    -- End the selection before moving so it cannot move the destination view.
    vim.cmd("normal! \27")
  else
    selections[win][buf] = nil
  end

  move()

  local saved = (selections[vim.api.nvim_get_current_win()] or {})[vim.api.nvim_get_current_buf()]
  if saved then
    -- Visual marks are shared by a buffer. Restore explicit positions instead
    -- so two windows showing the same file can retain separate selections.
    vim.fn.setpos(".", saved.anchor)
    vim.cmd("normal! " .. saved.mode)
    vim.fn.setpos(".", saved.cursor)
    vim.fn.winrestview(saved.view)
  end
end

function M.setup()
  for key, direction in pairs({ ["<Tab>"] = "next", ["<S-Tab>"] = "prev" }) do
    vim.keymap.set({ "n", "x" }, key, function()
      switch(function() require("nvchad.tabufline")[direction]() end)
    end, { desc = direction == "next" and "Next buffer" or "Previous buffer" })
  end

  for direction, name in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
    local function navigate()
      switch(function() vim.cmd.wincmd(direction) end)
    end
    for _, key in ipairs({ "<C-" .. direction .. ">", "<C-w>" .. direction }) do
      vim.keymap.set({ "n", "x" }, key, navigate, { desc = "Switch window " .. name })
    end
  end

  vim.api.nvim_create_autocmd("WinClosed", {
    group = vim.api.nvim_create_augroup("VisualNavigation", { clear = true }),
    callback = function(event) selections[tonumber(event.match)] = nil end,
  })
end

return M
