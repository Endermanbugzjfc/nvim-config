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

function M.reveal_current_buffer()
  local files = require "mini.files"
  local state = files.get_explorer_state()
  local win = vim.api.nvim_get_current_win()
  if state and vim.bo.filetype:match("^minifiles") then
    win = state.target_window
  end
  local path = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
  local stat = vim.uv.fs_stat(path)
  local directory = path == "" and vim.fn.getcwd() or vim.fs.dirname(path)
  if stat and stat.type == "directory" then directory = path end
  if not directory or vim.fn.isdirectory(directory) == 0 then
    vim.notify("Current buffer has no directory to reveal", vim.log.levels.INFO)
    return
  end

  -- Resume first, then navigate the existing explorer so pending edits survive.
  if hidden[vim.api.nvim_get_current_tabpage()] or not state then files.open(directory) end
  files.set_target_window(win)
  local branch = { directory }
  if stat and stat.type == "file" then table.insert(branch, path) end
  files.set_branch(branch, { depth_focus = 1 })
end

function M.go_to_git_root()
  local files = require "mini.files"
  local state = files.get_explorer_state()
  local win = vim.api.nvim_get_current_win()
  local directory
  if state and vim.bo.filetype:match("^minifiles") then
    directory = state.branch[state.depth_focus]
    win = state.target_window
  else
    local path = vim.api.nvim_buf_get_name(0)
    local stat = vim.uv.fs_stat(path)
    directory = path == "" and vim.fn.getcwd() or vim.fs.dirname(path)
    if stat and stat.type == "directory" then directory = path end
  end
  if not directory then return end

  local ok, process = pcall(vim.system, { "git", "-C", directory, "rev-parse", "--show-toplevel" }, { text = true })
  if not ok then return end
  local result = process:wait()
  if result.code ~= 0 then return end
  local root = result.stdout:gsub("\r?\n$", "")

  if hidden[vim.api.nvim_get_current_tabpage()] or not state then files.open(root) end
  files.set_target_window(win)
  files.set_branch({ root }, { depth_focus = 1 })
end

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
  local cwd_namespace = vim.api.nvim_create_namespace("MiniFilesCwdBorder")
  local border_namespaces = {}
  local function set_cwd_highlights()
    for _, name in ipairs({ "FloatBorder", "MiniFilesBorder", "MiniFilesBorderModified" }) do
      vim.api.nvim_set_hl(cwd_namespace, name, { fg = "#ff5555" })
    end
  end
  local function canonical(path)
    return vim.uv.fs_realpath(path) or vim.fs.normalize(path)
  end
  local function update_cwd_borders()
    local state = files.get_explorer_state()
    if not state then return end
    local cwd = canonical(vim.fn.getcwd())
    for _, window in ipairs(state.windows) do
      local win = window.win_id
      if vim.api.nvim_win_is_valid(win) then
        if window.path and canonical(window.path) == cwd then
          if border_namespaces[win] == nil then
            border_namespaces[win] = vim.api.nvim_get_hl_ns({ winid = win })
          end
          vim.api.nvim_win_set_hl_ns(win, cwd_namespace)
        elseif border_namespaces[win] ~= nil then
          vim.api.nvim_win_set_hl_ns(win, border_namespaces[win])
          border_namespaces[win] = nil
        end
      end
    end
  end
  set_cwd_highlights()
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "MiniFilesWindowUpdate",
    callback = update_cwd_borders,
  })
  vim.api.nvim_create_autocmd("DirChanged", {
    group = group,
    callback = update_cwd_borders,
  })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      set_cwd_highlights()
      update_cwd_borders()
    end,
  })
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(event) border_namespaces[tonumber(event.match)] = nil end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "MiniFilesBufferCreate",
    callback = function(event)
      local buf = event.data.buf_id
      vim.keymap.set("n", "q", M.hide, { buffer = buf, desc = "Hide explorer" })
      vim.keymap.set("n", "<Del>", function()
        local state = files.get_explorer_state()
        local directory = state and state.branch[state.depth_focus]
        if not directory or vim.fn.isdirectory(directory) == 0 then return end
        vim.api.nvim_set_current_dir(directory)
        update_cwd_borders()
      end, { buffer = buf, desc = "Set cwd to focused directory" })
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
