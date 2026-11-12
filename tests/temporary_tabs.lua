-- Run: LANG=en_US NVIM_LOG_FILE=/tmp/nvim-temporary-tabs.log nvim -n --headless -u NONE -i NONE -l tests/temporary_tabs.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
for _, plugin in ipairs({ "ui", "nvim-web-devicons", "mini.nvim" }) do
  vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/" .. plugin)
end
vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46/"
require "nvchad.tabufline.lazyload"
local tabs = require "configs.temporary_tabs"
tabs.setup()
local render = require "nvchad.tabufline.modules"
local root = vim.fn.tempname()
vim.fn.mkdir(root, "p")
local sequence = 0
local function drain()
  vim.wait(20, function() return false end)
end
local function open()
  sequence = sequence + 1
  local path = root .. "/file" .. sequence .. ".txt"
  vim.fn.writefile({ "alpha beta gamma", "second line", "third line" }, path)
  vim.cmd.edit(path)
  drain()
  return vim.api.nvim_get_current_buf(), path
end
local function keys(input)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(input, true, false, true), "mtx", false)
  drain()
end
local function visible(buf)
  return vim.bo[buf].buflisted and vim.tbl_contains(vim.t.bufs or {}, buf)
end

local first = open()
assert(tabs.is_temporary(first), "new files should be temporary")
local output = render()
assert(output:find("%%#TemporaryTabTbBufOn#"), "temporary tab did not render italic")
assert(vim.api.nvim_get_hl(0, { name = "TemporaryTabTbBufOn" }).italic)
local second = open()
assert(not visible(first), "unvisited file should hide on focus loss")
assert(vim.api.nvim_buf_is_loaded(first), "hiding must preserve the buffer")
assert(visible(second) and tabs.is_temporary(second))
vim.cmd.badd(root .. "/background.txt")
local background = vim.fn.bufnr(root .. "/background.txt")
assert(tabs.is_temporary(background), "background tabs should also start temporary")

vim.api.nvim_set_current_buf(first)
drain()
assert(visible(first) and tabs.is_temporary(first), "hidden preview should reopen")
assert(not visible(second))
-- Programmatic cursor restoration while opening a buffer is not user motion.
vim.api.nvim_win_set_cursor(0, { 2, 0 })
vim.api.nvim_exec_autocmds("CursorMoved", {})
vim.cmd "normal! j"
assert(tabs.is_temporary(first))
keys("j")
assert(not tabs.is_temporary(first), "motion should keep a tab")
assert(not render():find("TemporaryTabTbBufOn", 1, true), "kept tabs should stop being italic")
open()
assert(visible(first), "kept tab should survive focus loss")

-- Explicitly hiding a kept tab resets it for its next appearance.
local reopened, reopened_path = open()
keys("w")
assert(not tabs.is_temporary(reopened))
open()
vim.bo[reopened].buflisted = false
vim.api.nvim_set_current_buf(reopened)
drain()
assert(visible(reopened) and tabs.is_temporary(reopened), "hidden kept buffer should reopen as temporary")
assert(render():find("%%#TemporaryTabTbBufOn#"), "reopened buffer should render italic")
open()
assert(not visible(reopened), "reopened buffer should hide again on focus loss")
vim.cmd.edit(reopened_path)
drain()
assert(visible(reopened) and tabs.is_temporary(reopened), ":edit should also reopen hidden buffers as temporary")
keys("w")
assert(not tabs.is_temporary(reopened), "a motion should keep the reopened buffer")

-- Include motions at boundaries, counts, prefixes, and mapped motions.
for _, motion in ipairs({ "h", "0", "10j", "gg", "ge", "fZ", "[m", "<Down>", "<C-D>", "yw" }) do
  local buf = open()
  keys(motion)
  assert(not tabs.is_temporary(buf), "motion did not keep tab: " .. motion)
end
for _, motion in ipairs({ "w", "gg", "10j" }) do
  vim.keymap.set("n", "Q", motion)
  local mapped = open()
  keys("Q")
  assert(not tabs.is_temporary(mapped), "remapped motion should keep tab: " .. motion)
end
vim.keymap.set("n", "X", function() vim.api.nvim_win_set_cursor(0, { 2, 0 }) end)
local lua_motion = open()
keys("X")
assert(not tabs.is_temporary(lua_motion), "Lua cursor mapping should keep tab")

local searching = open()
keys("/beta<CR>")
assert(not tabs.is_temporary(searching), "search motion should keep tab")
local cancelled = open()
keys("/beta<Esc>")
assert(tabs.is_temporary(cancelled), "cancelled search should remain temporary")
local command = open()
keys(":let g:temporary_tabs_test = 'hello'<CR>")
assert(tabs.is_temporary(command), "command-line text should not count as motion")
keys("g<Esc>")
assert(tabs.is_temporary(command), "cancelled motion prefix should remain temporary")

-- Tab and split navigation must not treat their component keys as motions.
vim.keymap.set("n", "<Tab>", function() vim.api.nvim_set_current_buf(first) end)
local switching = open()
keys("<Tab>")
assert(tabs.is_temporary(switching) and not visible(switching), "tab navigation should hide previews")
local split = open()
vim.cmd "vsplit"
vim.api.nvim_set_current_buf(first)
drain()
assert(not visible(split), "losing focus to another split should hide preview")
keys("<C-w>w")
assert(vim.api.nvim_get_current_buf() == split, "expected to focus the preview split")
keys("<C-w>w")
assert(tabs.is_temporary(split) and not visible(split), "window motion should hide the departing preview")
vim.cmd "only"
drain()

local edited = open()
keys("iCHANGED<Esc>")
assert(not tabs.is_temporary(edited), "editing should keep a tab")
open()
assert(visible(edited), "modified file should not hide")

-- Empty tab lists must remain compatible with NvChad's BufAdd handler.
vim.cmd "tabnew"
local scratch = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(scratch)
drain()
assert(#vim.t.bufs == 0, "expected every preview to be hidden")
assert(vim.bo[scratch].buftype == "nofile" and not tabs.is_temporary(scratch))
local after_empty = open()
assert(visible(after_empty) and tabs.is_temporary(after_empty))

-- A floating file explorer hides the preview and restores its tab on return.
require("configs.mini_files").setup { windows = { preview = true } }
local files = require "mini.files"
files.open(root)
drain()
assert(not visible(after_empty), "explorer focus should hide the preview")
files.close()
drain()
assert(visible(after_empty) and tabs.is_temporary(after_empty), "returning from explorer should restore the preview")

-- Italic groups inherit refreshed theme colors on the next render.
vim.api.nvim_set_hl(0, "TbBufOn", { fg = "#123456", bg = "#abcdef" })
render()
local highlight = vim.api.nvim_get_hl(0, { name = "TemporaryTabTbBufOn" })
assert(highlight.italic and highlight.fg == 0x123456 and highlight.bg == 0xabcdef)
vim.fn.delete(root, "rf")
print "PASS: temporary tabs, italics, hiding/reopening, motions, edits, splits, and NvChad integration"
