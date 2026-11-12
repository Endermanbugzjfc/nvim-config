local M = {}
local api = vim.api

function M.is_temporary(buf)
  return api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" and vim.b[buf].temporary_tab == true
end

function M.keep(buf)
  if not M.is_temporary(buf) then return end
  vim.b[buf].temporary_tab = false
  vim.cmd "redrawtabline"
end

function M.setup()
  if M.initialized then return end
  M.initialized = true

  -- Install before the tabline renderer captures style_buf. Preserve NvChad's
  -- icons, click targets, truncation, and colors, adding only the italic style.
  local utils = require "nvchad.tabufline.utils"
  local style_buf = utils.style_buf
  utils.style_buf = function(buf, ...)
    local text = style_buf(buf, ...)
    if not M.is_temporary(buf) then return text end
    return (text:gsub("%%#([^#]+)#", function(name)
      local highlight = api.nvim_get_hl(0, { name = name, link = false })
      highlight.italic = true
      local temporary = "TemporaryTab" .. name
      api.nvim_set_hl(0, temporary, highlight)
      return "%#" .. temporary .. "#"
    end))
  end

  local group = api.nvim_create_augroup("TemporaryTabs", { clear = true })
  local insert_prefix
  local function mark(buf)
    if vim.bo[buf].buftype == "" and vim.bo[buf].buflisted and vim.b[buf].temporary_tab == nil then
      vim.b[buf].temporary_tab = not vim.bo[buf].modified
    end
  end
  api.nvim_create_autocmd("BufAdd", {
    group = group,
    callback = function(event) mark(event.buf) end,
  })
  api.nvim_create_autocmd("BufDelete", {
    group = group,
    callback = function(event)
      local buf = event.buf
      -- Unlisting also hides kept tabs. Their next appearance is a new preview.
      if api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" then
        vim.b[buf].temporary_tab = not vim.bo[buf].modified
      end
    end,
  })
  local function entered(event)
    insert_prefix = nil
    local buf = event.buf
    if vim.bo[buf].buftype ~= "" then return end
    mark(buf)
    if M.is_temporary(buf) then
      -- A hidden preview can be revisited through the jumplist, :buffer, etc.
      vim.bo[buf].buflisted = true
      local bufs = vim.t.bufs or {}
      if not vim.tbl_contains(bufs, buf) then
        table.insert(bufs, buf)
        vim.t.bufs = bufs
      end
    end
  end
  api.nvim_create_autocmd("BufEnter", { group = group, callback = entered })
  api.nvim_create_autocmd("WinEnter", {
    group = group,
    callback = function() insert_prefix = nil end,
  })

  api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
    group = group,
    callback = function(event)
      local buf = event.buf
      if not M.is_temporary(buf) then return end
      -- Wait until the destination window/buffer has actually received focus.
      vim.schedule(function()
        if not M.is_temporary(buf) or api.nvim_get_current_buf() == buf then return end
        if vim.bo[buf].modified then
          M.keep(buf)
          return
        end
        -- Unlist without deleting: preserve contents, undo history and jumps.
        vim.bo[buf].buflisted = false
        for _, tab in ipairs(api.nvim_list_tabpages()) do
          local bufs = vim.t[tab].bufs
          if bufs then
            vim.t[tab].bufs = vim.tbl_filter(function(nr) return nr ~= buf end, bufs)
          end
        end
        vim.cmd "redrawtabline"
      end)
    end,
  })

  -- NvChad's BufAdd handler indexes the first entry without checking for an
  -- empty list. Refill it for listed file buffers, not transient picker buffers.
  api.nvim_create_autocmd("BufNew", {
    group = group,
    callback = function(event)
      if vim.t.bufs and #vim.t.bufs == 0 and vim.bo[event.buf].buflisted and vim.bo[event.buf].buftype == "" then
        vim.t.bufs = { event.buf }
      end
    end,
  })
  api.nvim_create_autocmd({ "InsertEnter", "TextChanged", "TextChangedI", "BufWritePost" }, {
    group = group,
    callback = function(event) M.keep(event.buf) end,
  })
  api.nvim_create_autocmd("BufModifiedSet", {
    group = group,
    callback = function(event)
      if vim.bo[event.buf].modified then M.keep(event.buf) end
    end,
  })

  -- 'readonly' buffers still emit InsertEnter. 'nomodifiable' buffers reject
  -- insertion before that event, so recognize their insert commands directly.
  vim.on_key(function(key)
    local buf = api.nvim_get_current_buf()
    local mode = api.nvim_get_mode().mode
    if not M.is_temporary(buf) or vim.bo[buf].modifiable or not (mode == "n" or mode:match("^[vV\22]")) then
      insert_prefix = nil
      return
    end
    local char = vim.fn.keytrans(key)
    if insert_prefix then
      local previous = insert_prefix
      insert_prefix = nil
      if previous == "g" and mode == "n" and char:match("^[iIR]$") then M.keep(buf) end
      if previous == "g" and char:match("^['`r]$") then insert_prefix = "argument" end
      if previous == "window" and char:match("^%d$") then insert_prefix = "window" end
      return
    end
    if char == "g" then
      insert_prefix = "g"
    elseif char == "<C-W>" then
      insert_prefix = "window"
    elseif char:match("^[fFtT'`\"mr@%[%]z]$") or (char == "q" and vim.fn.reg_recording() == "") then
      -- These commands read an argument; e.g. fi and 'i do not insert text.
      insert_prefix = "argument"
    elseif char:match(mode == "n" and "^[iIaAoOsScCR]$" or "^[IAsScCR]$") or char == "<Insert>" then
      M.keep(buf)
    end
  end, api.nvim_create_namespace("TemporaryTabInsertAttempts"))
  for _, buf in ipairs(api.nvim_list_bufs()) do
    mark(buf)
  end
end

return M
