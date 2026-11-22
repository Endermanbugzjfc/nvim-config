-- Run: NVIM_LOG_FILE=/tmp/nvim-undo-selection.log nvim -n --headless -u NONE -i NONE -l tests/undo_selection.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
require("configs.paste").setup()

local function keys(input)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(input, true, false, true), "xt", false)
end

local function reset(lines)
  keys("<Esc>")
  vim.cmd "enew!"
  local levels = vim.bo.undolevels
  vim.bo.undolevels = -1
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.bo.undolevels = levels
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

local function selected(expected)
  keys("gV")
  if expected == nil then
    assert(vim.fn.mode() == "n", "operation without restored text selected something")
  else
    assert(vim.fn.mode() == "v", "restored text was not selected")
    local actual = table.concat(vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = "v" }), "\n")
    assert(actual == expected, vim.inspect({ expected = expected, actual = actual }))
    keys("<Esc>")
  end
end

reset({ "alpha beta" })
keys("dw")
keys("u")
selected("alpha ")
keys("<C-r>")
selected(nil)

reset({ "alpha" })
keys("A beta<Esc>")
keys("u")
selected(nil)
keys("<C-r>")
selected(" beta")

reset({ "before αβ after" })
keys("wde")
keys("g-")
selected("αβ")
keys("g+")
selected(nil)

reset({ "one", "two", "three" })
keys("dd")
keys("u")
selected("one")
keys("<C-r>")
selected(nil)

reset({ "alpha beta" })
keys("cwNEW<Esc>")
keys("u")
selected("alpha")
keys("<C-r>")
selected("NEW")

-- A later ordinary put still uses its own boundaries.
vim.fn.setreg("a", "PASTE", "v")
keys('"ap')
selected("PASTE")

-- An unrelated edit must not revive a selection after a removal-only undo.
reset({ "base" })
keys("A extra<Esc>u")
selected(nil)
keys("A unrelated<Esc>")
selected(nil)
vim.api.nvim_paste("BRACKETED", false, -1)
selected("BRACKETED")

-- A put takes over from undo, including named registers and counts.
for _, command in ipairs({ "p", "P", "gp", "gP" }) do
  reset({ "base" })
  keys("xugV<Esc>")
  vim.fn.setreg("a", "TEXT", "v")
  keys('"a2' .. command)
  selected("TEXTTEXT")
end

-- Multiple undo blocks can restore several lines at once.
reset({ "one", "two", "three" })
keys("dd")
keys("dd")
keys("2u")
selected("one\ntwo")
print("PASS: gV selects restored text for undo/redo/history, skips removals, and preserves puts")
