local M = {}

function M.setup()
  vim.keymap.set("n", "gV", "`[v`]", { desc = "Select last pasted text" })

  -- InsertLeave otherwise expands '[ and '] to the whole insert session.
  -- Keep bracketed-paste boundaries separate until that session ends.
  local paste = vim.paste
  local pending
  vim.paste = function(lines, phase)
    if phase == -1 or phase == 1 then
      pending = nil
    end

    local buf = vim.api.nvim_get_current_buf()
    local tick = vim.api.nvim_buf_get_changedtick(buf)
    local result = paste(lines, phase)
    if result and vim.fn.mode():match("^i") and vim.api.nvim_buf_get_changedtick(buf) ~= tick then
      pending = {
        buf = buf,
        first = pending and pending.first or vim.api.nvim_buf_get_mark(buf, "["),
        last = vim.api.nvim_buf_get_mark(buf, "]"),
      }
    end
    return result
  end

  vim.api.nvim_create_autocmd("InsertLeave", {
    group = vim.api.nvim_create_augroup("SelectLastPaste", { clear = true }),
    callback = function(event)
      if pending and pending.buf == event.buf then
        vim.api.nvim_buf_set_mark(event.buf, "[", pending.first[1], pending.first[2], {})
        vim.api.nvim_buf_set_mark(event.buf, "]", pending.last[1], pending.last[2], {})
      end
      pending = nil
    end,
  })
end

return M
