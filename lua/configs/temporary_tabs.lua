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
  local prefix, count
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
    prefix, count = nil, nil
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
    callback = function() prefix, count = nil, nil end,
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
  -- empty list. Refill it before BufAdd when every preview has been hidden.
  api.nvim_create_autocmd("BufNew", {
    group = group,
    callback = function(event)
      if vim.t.bufs and #vim.t.bufs == 0 then vim.t.bufs = { event.buf } end
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

  local motions = {}
  for char in ("h j k l w W b B e E 0 ^ $ _ + - G H M L % { } ( ) | ; , n N * # <Space> <BS> <CR> "
    .. "<Left> <Right> <Up> <Down> <Home> <End> <S-Left> <S-Right> <S-Up> <S-Down> "
    .. "<C-Left> <C-Right> <C-Home> <C-End> <C-B> <C-F> <C-D> <C-U> <C-E> <C-Y> "
    .. "<PageUp> <PageDown> <C-O> <C-I> <C-]> <C-T>"):gmatch("%S+") do
    motions[char] = true
  end
  local prefixed = {
    g = "gjk0^$_eEGHMm;,dDfF*#nNvV",
    ["["] = "[]{}()mMdDcCfF/`'sz",
    ["]"] = "[]{}()mMdDcCfF/`'sz",
    z = "t.zb^-+HhLl",
  }
  vim.on_key(function(key, typed)
    local buf = api.nvim_get_current_buf()
    local mode = api.nvim_get_mode().mode
    if not M.is_temporary(buf) or not (mode:match("^n") or mode:match("^[vV\22]")) then
      prefix, count = nil, nil
      return
    end

    -- Plugins use :normal! to restore views while opening files/explorers.
    -- Only accept non-typed keys when continuing a user motion or a macro.
    if typed == "" and not prefix and not count and vim.fn.reg_executing() == "" then return end

    local char = vim.fn.keytrans(key)
    if prefix then
      local previous = prefix
      prefix, count = nil, nil
      if previous == "g" and (char == "'" or char == "`") then
        prefix = "argument"
        return
      end
      if char ~= "<Esc>" and (previous == "argument"
        or (prefixed[previous] and #char == 1 and prefixed[previous]:find(char, 1, true))
        or (previous == "g" and (char == "<Home>" or char == "<End>" or char == "<C-]>"))
        or (previous == "z" and char == "<CR>")) then
        M.keep(buf)
      end
      return
    end
    if char:match("^[1-9]$") or (count and char == "0") then
      count = true
      return
    end
    count = nil
    if prefixed[char] then
      prefix = char
    elseif char:match("^[fFtT'`]$") then
      prefix = "argument"
    elseif char == "<C-W>" or char == '"' or char:match("^[mq@r]$") then
      prefix = "ignore"
    elseif motions[char] then
      M.keep(buf)
    elseif char == "/" or char == "?" then
      -- Wait for CmdlineLeave so a cancelled incremental search stays temporary.
      return
    else
      -- Also recognize cursor motion implemented by a Lua mapping. Compare the
      -- same window and buffer, so a picker or tab switch cannot keep a preview.
      local win, cursor = api.nvim_get_current_win(), api.nvim_win_get_cursor(0)
      vim.schedule(function()
        if api.nvim_win_is_valid(win) and api.nvim_get_current_win() == win
          and api.nvim_get_current_buf() == buf and not vim.deep_equal(api.nvim_win_get_cursor(win), cursor) then
          M.keep(buf)
        end
      end)
    end
  end, api.nvim_create_namespace("TemporaryTabMotions"))

  api.nvim_create_autocmd("CmdlineLeave", {
    group = group,
    callback = function()
      local kind = vim.fn.getcmdtype()
      if (kind == "/" or kind == "?") and not vim.v.event.abort then M.keep(api.nvim_get_current_buf()) end
    end,
  })
  for _, buf in ipairs(api.nvim_list_bufs()) do
    mark(buf)
  end
end

return M
