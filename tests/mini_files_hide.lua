-- Run: LANG=en_US XDG_STATE_HOME=/tmp/nvim-mini-files-test-state NVIM_LOG_FILE=/tmp/mini-files-hide.log nvim -n --headless -u NONE -i NONE -l tests/mini_files_hide.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/mini.nvim")
vim.o.columns = 160
require("configs.mini_files").setup { windows = { preview = true } }
local files = require "mini.files"
local root = vim.fn.tempname()
vim.fn.mkdir(root .. "/nested", "p")
vim.fn.writefile({ "original" }, root .. "/nested/original.txt")

local confirmations, answer = 0, 2
vim.fn.confirm = function()
  confirmations = confirmations + 1
  return answer
end
local function key(lhs)
  local mapping = vim.fn.maparg(lhs, "n", false, true)
  assert(type(mapping.callback) == "function", "missing mapping: " .. lhs)
  mapping.callback()
end
local function drain(ms)
  vim.wait(ms or 30, function() return false end)
end
local function lines(buf)
  return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
end
local function changed(buf)
  vim.api.nvim_exec_autocmds("TextChanged", { buffer = buf })
  vim.api.nvim_exec_autocmds("CursorMoved", { buffer = buf })
  drain()
end

files.open(root)
files.set_branch({ root, root .. "/nested" })
drain()
local buf = vim.api.nvim_get_current_buf()
local original = lines(buf)
-- Use a real normal-mode edit so undo preservation is also exercised.
vim.cmd "normal! A.renamed"
changed(buf)
local edited, cursor = lines(buf), vim.api.nvim_win_get_cursor(0)
assert(not vim.deep_equal(original, edited))
local before = files.get_explorer_state()
-- A cursor callback can still be queued when the user presses q.
vim.api.nvim_exec_autocmds("CursorMoved", { buffer = buf })
key "q"
drain()
assert(vim.api.nvim_get_current_win() == before.target_window)
for _, window in ipairs(before.windows) do
  assert(vim.api.nvim_win_get_config(window.win_id).hide)
end
-- Wait beyond the plugin's focus timer and exercise its resize callback.
vim.api.nvim_exec_autocmds("VimResized", {})
drain(1200)
assert(vim.api.nvim_get_current_win() == before.target_window, "queued refresh stole focus while hidden")
assert(confirmations == 0, "hiding prompted to discard")
assert(vim.api.nvim_buf_is_valid(buf))
assert(vim.deep_equal(lines(buf), edited))
assert(vim.uv.fs_stat(root .. "/nested/original.txt"))
assert(not vim.uv.fs_stat(root .. "/nested/original.txt.renamed"))

-- Even opening from a different path must resume the hidden session.
files.open(root .. "/nested/original.txt")
drain()
assert(vim.api.nvim_get_current_buf() == buf)
assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), cursor))
assert(vim.deep_equal(files.get_explorer_state().branch, before.branch))
for _, window in ipairs(files.get_explorer_state().windows) do
  assert(not vim.api.nvim_win_get_config(window.win_id).hide)
end
vim.cmd "undo"
changed(buf)
assert(vim.deep_equal(lines(buf), original), "hiding lost undo history")
vim.cmd "redo"
changed(buf)
assert(vim.deep_equal(lines(buf), edited))

-- Refusing discard preserves edits; accepting discards without touching disk.
key "<BS>"
assert(confirmations == 1)
assert(vim.deep_equal(lines(buf), edited))
answer = 1
key "<BS>"
drain()
assert(confirmations == 2)
assert(vim.deep_equal(lines(buf), original))
assert(vim.uv.fs_stat(root .. "/nested/original.txt"))
assert(not vim.uv.fs_stat(root .. "/nested/original.txt.renamed"))

-- A resumed session must still support normal synchronization.
-- Account for the plugin's own refresh before the next user edit (headless
-- scripts do not return to the interactive loop to emit TextChanged).
vim.api.nvim_exec_autocmds("TextChanged", { buffer = buf })
vim.cmd "normal! A.renamed"
changed(buf)
key "q"
drain()
files.open(root)
files.synchronize()
assert(confirmations == 3, "expected sync confirmation, got " .. confirmations .. "; " .. vim.inspect(lines(buf)))
assert(vim.uv.fs_stat(root .. "/nested/original.txt.renamed"))
assert(not vim.uv.fs_stat(root .. "/nested/original.txt"))
files.close()

-- Hidden sessions are independent across tabs, including pending creations.
files.open(root)
local first_tab = vim.api.nvim_get_current_tabpage()
local first_buf = vim.api.nvim_get_current_buf()
vim.api.nvim_exec_autocmds("TextChanged", { buffer = first_buf })
vim.cmd "normal! Gopending.txt"
changed(first_buf)
local pending = lines(first_buf)
key "q"
drain()
vim.cmd "tabnew"
local second_tab = vim.api.nvim_get_current_tabpage()
files.open(root .. "/nested")
key "q"
drain()
vim.api.nvim_set_current_tabpage(first_tab)
files.open(root .. "/nested")
assert(vim.api.nvim_get_current_buf() == first_buf)
assert(vim.deep_equal(lines(first_buf), pending))
assert(confirmations == 3)
assert(not vim.uv.fs_stat(root .. "/pending.txt"))
key "<BS>"
assert(confirmations == 4)
files.close()
vim.api.nvim_set_current_tabpage(second_tab)
vim.cmd "tabclose"
vim.fn.delete(root, "rf")
print "PASS: hide/resume preserves edits, branch, cursor and undo across tabs; discard confirms; synchronization still works"
