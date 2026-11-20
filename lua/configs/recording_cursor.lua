local M = {}

local function update_highlight()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local background = normal.bg or (vim.o.background == "light" and 0xffffff or 0x000000)
  local green = 0x00ff00
  local mixed = 0

  -- A cursor cannot be translucent in the terminal. Blend its color with the
  -- theme background for the same visual effect.
  for _, shift in ipairs({ 16, 8, 0 }) do
    local base_channel = math.floor(background / 2 ^ shift) % 256
    local green_channel = math.floor(green / 2 ^ shift) % 256
    mixed = mixed + math.floor((base_channel + green_channel) / 2 + 0.5) * 2 ^ shift
  end

  vim.api.nvim_set_hl(0, "MacroRecordingCursor", { bg = string.format("#%06x", mixed) })
end

function M.setup()
  local saved_cursor
  local group = vim.api.nvim_create_augroup("MacroRecordingCursor", { clear = true })

  update_highlight()
  vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = update_highlight })
  vim.api.nvim_create_autocmd("RecordingEnter", {
    group = group,
    callback = function()
      saved_cursor = vim.o.guicursor
      vim.o.guicursor = saved_cursor .. ",a:ver25-MacroRecordingCursor"
    end,
  })
  vim.api.nvim_create_autocmd("RecordingLeave", {
    group = group,
    callback = function()
      if saved_cursor then
        vim.o.guicursor = saved_cursor
        saved_cursor = nil
      end
    end,
  })
end

return M
