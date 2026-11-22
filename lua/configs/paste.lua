local M = {}
local restored = {}
local namespace = vim.api.nvim_create_namespace("SelectRestoredText")

local function position(lines, offset)
  for row, line in ipairs(lines) do
    if offset <= #line then
      local col = math.min(offset, math.max(#line - 1, 0))
      -- A byte diff can begin inside a multibyte character.
      while col > 0 and (line:byte(col + 1) or 0) >= 128 and line:byte(col + 1) < 192 do col = col - 1 end
      return { row, col }
    end
    offset = offset - #line - 1
  end
  return { #lines, math.max(#lines[#lines] - 1, 0) }
end

local function undo(command)
  local buf = vim.api.nvim_get_current_buf()
  local before = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  vim.cmd.normal({ tostring(vim.v.count1) .. command, bang = true })
  local after = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local selection = {}
  -- Undo can touch several lines or separate regions. Find the smallest range
  -- containing restored text, trimming unchanged text from each changed hunk.
  for _, hunk in ipairs(vim.diff(table.concat(before, "\n") .. "\n", table.concat(after, "\n") .. "\n", {
    result_type = "indices",
    algorithm = "minimal",
  })) do
    local old_start, old_count, new_start, new_count = unpack(hunk)
    if new_count > 0 then
      local old = old_count > 0 and table.concat(before, "\n", old_start, old_start + old_count - 1) .. "\n" or ""
      local new = table.concat(after, "\n", new_start, new_start + new_count - 1) .. "\n"
      local first, last, old_last = 1, #new, #old
      while first <= last and first <= old_last and new:byte(first) == old:byte(first) do first = first + 1 end
      while last >= first and old_last >= first and new:byte(last) == old:byte(old_last) do
        last, old_last = last - 1, old_last - 1
      end
      if first <= last then
        local offset = 0
        for line = 1, new_start - 1 do offset = offset + #after[line] + 1 end
        selection.first = math.min(selection.first or math.huge, offset + first - 1)
        selection.last = math.max(selection.last or -1, offset + last - 1)
      end
    end
  end
  vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
  restored[buf] = {}
  if selection.first then
    for _, boundary in ipairs({ "first", "last" }) do
      local pos = position(after, selection[boundary])
      restored[buf][boundary] = vim.api.nvim_buf_set_extmark(buf, namespace, pos[1] - 1, pos[2], {})
    end
  end
end

local function select_restored()
  local buf = vim.api.nvim_get_current_buf()
  local selection = restored[buf]
  if not selection then
    return "`[v`]"
  end
  if not selection.first then return "" end
  local first = vim.api.nvim_buf_get_extmark_by_id(buf, namespace, selection.first, {})
  local last = vim.api.nvim_buf_get_extmark_by_id(buf, namespace, selection.last, {})
  return string.format("<Cmd>call cursor(%d,%d)<CR>v<Cmd>call cursor(%d,%d)<CR>", first[1] + 1, first[2] + 1, last[1] + 1, last[2] + 1)
end

function M.setup()
  vim.keymap.set("n", "gV", select_restored, { expr = true, desc = "Select last pasted or restored text" })
  for _, command in ipairs({ "u", "\18", "g-", "g+" }) do
    vim.keymap.set("n", command, function() undo(command) end, { desc = "Undo history: " .. vim.fn.keytrans(command) })
  end
  for _, command in ipairs({ "p", "P", "gp", "gP" }) do
    vim.keymap.set("n", command, function()
      restored[vim.api.nvim_get_current_buf()] = nil
      vim.cmd.normal({ '"' .. vim.v.register .. tostring(vim.v.count1) .. command, bang = true })
    end, { desc = "Put text: " .. command })
  end

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
    if result and vim.api.nvim_buf_get_changedtick(buf) ~= tick then restored[buf] = nil end
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
