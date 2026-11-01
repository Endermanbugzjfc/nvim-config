-- Run: XDG_STATE_HOME=/tmp/nvim-mini-files-cwd-state NVIM_LOG_FILE=/tmp/mini-files-cwd.log nvim -n --headless -u NONE -i NONE -l tests/mini_files_cwd.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/mini.nvim")
vim.o.columns = 160
local original_cwd = vim.fn.getcwd()
require("configs.mini_files").setup { windows = { preview = true } }
local files = require "mini.files"
local root = vim.fn.tempname()
vim.fn.mkdir(root .. "/empty", "p")
vim.fn.writefile({ "example" }, root .. "/file.txt")
vim.api.nvim_set_current_dir(root)
files.open(root)
files.set_branch({ root, root .. "/empty" }, { depth_focus = 2 })

local namespace = vim.api.nvim_get_namespaces().MiniFilesCwdBorder
local function window(path)
  for _, item in ipairs(files.get_explorer_state().windows) do
    if item.path == path then return item.win_id end
  end
  error("Missing explorer pane for " .. path)
end
local function is_red(path)
  return vim.api.nvim_get_hl_ns({ winid = window(path) }) == namespace
end
local function delete_key()
  local mapping = vim.fn.maparg("<Del>", "n", false, true)
  assert(type(mapping.callback) == "function", "Delete mapping is present in Mini.Files")
  mapping.callback()
end
assert(is_red(root), "cwd pane has a red border while another pane is focused")
assert(not is_red(root .. "/empty"), "non-cwd pane uses its normal border")
assert(vim.api.nvim_get_hl(namespace, { name = "FloatBorder" }).fg == 0xff5555)

delete_key()
assert(vim.fn.getcwd() == root .. "/empty", "Delete sets cwd to the focused empty directory")
assert(is_red(root .. "/empty"), "new cwd pane has the red border")
assert(not is_red(root), "old cwd pane returns to its original highlight namespace")
files.refresh()
assert(is_red(root .. "/empty"), "red border survives explorer refresh")

-- A directory entry under the cursor must not replace the focused pane's path.
files.set_branch({ root, root .. "/empty" }, { depth_focus = 1 })
assert(files.get_fs_entry().path == root .. "/empty", "child directory is selected")
delete_key()
assert(vim.fn.getcwd() == root, "Delete uses the focused pane rather than the selected entry")
assert(is_red(root) and not is_red(root .. "/empty"), "border follows the focused pane's cwd")

-- External cwd changes, theme changes and hide/resume keep the marker.
vim.api.nvim_set_current_dir(root .. "/empty")
assert(is_red(root .. "/empty") and not is_red(root), "external cwd changes update the borders")
vim.api.nvim_exec_autocmds("ColorScheme", {})
assert(is_red(root .. "/empty"), "theme changes preserve cwd marking")
require("configs.mini_files").hide()
vim.wait(50, function() return false end)
files.open(root)
assert(is_red(root .. "/empty"), "resuming a hidden explorer preserves cwd marking")
files.close()
vim.api.nvim_set_current_dir(original_cwd)
vim.fn.delete(root, "rf")
print "PASS: cwd borders, Delete on focused and empty directories, refresh, external cwd changes, theme changes, hide/resume"
