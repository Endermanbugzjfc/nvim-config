local M = {}
local hidden = {}

-- Let mini.files' scheduled cursor/preview updates finish before hiding.
M.hide = vim.schedule_wrap(function()
  local files = require "mini.files"
  local state = files.get_explorer_state()
  if not state then return end

  local tab = vim.api.nvim_get_current_tabpage()
  hidden[tab] = { state = state, focus = vim.api.nvim_get_current_win() }
  vim.api.nvim_set_current_win(state.target_window)
  for _, window in ipairs(state.windows) do
    vim.api.nvim_win_set_config(window.win_id, { hide = true })
  end
end)

function M.setup(opts)
  local files = require "mini.files"
  local open, close, refresh = files.open, files.close, files.refresh

  files.open = function(...)
    local tab = vim.api.nvim_get_current_tabpage()
    local session = hidden[tab]
    if not session then return open(...) end

    hidden[tab] = nil
    files.set_target_window(vim.api.nvim_get_current_win())
    for _, window in ipairs(session.state.windows) do
      if vim.api.nvim_win_is_valid(window.win_id) then
        vim.api.nvim_win_set_config(window.win_id, { hide = false })
      end
    end
    if vim.api.nvim_win_is_valid(session.focus) then
      vim.api.nvim_set_current_win(session.focus)
    end
    refresh()
  end

  -- mini.files periodically closes explorers that have lost focus. A hidden
  -- session must retain its buffers, pending edits, cursors, and undo history.
  files.close = function(...)
    if hidden[vim.api.nvim_get_current_tabpage()] then return false end
    return close(...)
  end
  files.refresh = function(...)
    if hidden[vim.api.nvim_get_current_tabpage()] then return end
    return refresh(...)
  end

  local group = vim.api.nvim_create_augroup("MiniFilesHide", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "MiniFilesBufferCreate",
    callback = function(event)
      local buf = event.data.buf_id
      vim.keymap.set("n", "q", M.hide, { buffer = buf, desc = "Hide explorer" })
      vim.keymap.set("n", "<BS>", function()
        -- A forced refresh asks about pending actions before discarding them.
        files.refresh { content = { filter = files.config.content.filter } }
      end, { buffer = buf, desc = "Discard pending changes" })
    end,
  })
  vim.api.nvim_create_autocmd("TabClosed", {
    group = group,
    callback = function()
      for tab in pairs(hidden) do
        if not vim.api.nvim_tabpage_is_valid(tab) then hidden[tab] = nil end
      end
    end,
  })

  -- Install our refresh wrapper before setup registers its resize callback.
  files.setup(opts)
end

return M
