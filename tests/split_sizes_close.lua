-- Run: NVIM_LOG_FILE=/tmp/nvim-split-close.log nvim --headless -n -u NONE -i NONE -l tests/split_sizes_close.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.o.lines = 60
vim.o.columns = 160
vim.o.splitbelow = false
vim.o.splitright = false
vim.o.winwidth = 1
require('configs.split_sizes').setup()

local function resized()
  vim.api.nvim_exec_autocmds('WinResized', {})
end

local function command(text)
  vim.cmd(text)
  resized()
end

local function eq(actual, expected, message)
  assert(actual == expected, message .. ': expected ' .. expected .. ', got ' .. actual)
end

local function close(win)
  vim.api.nvim_set_current_win(win)
  command('close')
end

for _, dimension in ipairs({ 'width', 'height' }) do
  local vertical = dimension == 'width'
  local split = vertical and 'vsplit' or 'split'
  local get = vertical and vim.api.nvim_win_get_width or vim.api.nvim_win_get_height
  local set = vertical and vim.api.nvim_win_set_width or vim.api.nvim_win_set_height
  command('only')
  command(split)
  command(split)
  local panes = vim.api.nvim_tabpage_list_wins(0)
  set(panes[1], vertical and 20 or 4)
  set(panes[2], vertical and 26 or 6)
  resized()
  local small, removed, large = get(panes[1]), get(panes[2]), get(panes[3])
  assert(large > removed and removed > small, 'test layout has a unique largest pane')
  close(panes[2])
  eq(get(panes[1]), small, 'smaller pane keeps its ' .. dimension)
  eq(get(panes[3]), large + removed + 1, 'largest pane absorbs the freed ' .. dimension)

  -- Closing the largest pane still protects the smallest survivor.
  command(split)
  panes = vim.api.nvim_tabpage_list_wins(0)
  set(panes[1], vertical and 18 or 3)
  set(panes[2], vertical and 24 or 5)
  resized()
  small, removed, large = get(panes[1]), get(panes[3]), get(panes[2])
  close(panes[3])
  eq(get(panes[1]), small, 'closing largest preserves smallest ' .. dimension)
  eq(get(panes[2]), large + removed + 1, 'largest survivor absorbs the freed ' .. dimension)
end

-- A nested close must not redistribute space in an unrelated split group.
command('only')
local bottom = vim.api.nvim_get_current_win()
command('split')
command('vsplit')
command('vsplit')
local layout = vim.fn.winlayout()
assert(layout[1] == 'col' and layout[2][1][1] == 'row', 'nested test layout')
local top = layout[2][1][2]
local small, removed, large = top[1][2], top[2][2], top[3][2]
vim.api.nvim_win_set_width(small, 19)
vim.api.nvim_win_set_width(removed, 25)
resized()
local old_width = vim.api.nvim_win_get_width(large)
local removed_width = vim.api.nvim_win_get_width(removed)
local bottom_height = vim.api.nvim_win_get_height(bottom)
local top_height = vim.api.nvim_win_get_height(small)
close(removed)
eq(vim.api.nvim_win_get_width(small), 19, 'nested small pane keeps its width')
eq(vim.api.nvim_win_get_width(large), old_width + removed_width + 1, 'nested largest pane grows')
eq(vim.api.nvim_win_get_height(bottom), bottom_height, 'unrelated pane keeps its height')
eq(vim.api.nvim_win_get_height(small), top_height, 'closing a vertical split preserves height')

-- Growing a nested branch still protects smaller panes inside that branch.
command('only')
local outer = vim.api.nvim_get_current_win()
command('leftabove vsplit')
local inner_bottom = vim.api.nvim_get_current_win()
command('aboveleft split')
local inner_large = vim.api.nvim_get_current_win()
command('leftabove vsplit')
local inner_small = vim.api.nvim_get_current_win()
vim.api.nvim_win_set_width(inner_small, 14)
resized()
local large_width = vim.api.nvim_win_get_width(inner_large)
local outer_width = vim.api.nvim_win_get_width(outer)
local bottom_width = vim.api.nvim_win_get_width(inner_bottom)
close(outer)
eq(vim.api.nvim_win_get_width(inner_small), 14, 'smaller descendant stays fixed when its branch grows')
eq(vim.api.nvim_win_get_width(inner_large), large_width + outer_width + 1, 'largest descendant absorbs branch growth')
eq(vim.api.nvim_win_get_width(inner_bottom), bottom_width + outer_width + 1, 'perpendicular sibling shares the expanded width')

-- Floating windows do not participate in split-space allocation.
local before = {}
for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
  before[win] = { vim.api.nvim_win_get_width(win), vim.api.nvim_win_get_height(win) }
end
local float = vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, {
  relative = 'editor', row = 1, col = 1, width = 12, height = 4,
})
vim.api.nvim_win_close(float, true)
resized()
for win, size in pairs(before) do
  eq(vim.api.nvim_win_get_width(win), size[1], 'closing a float preserves split width')
  eq(vim.api.nvim_win_get_height(win), size[2], 'closing a float preserves split height')
end

print('PASS: largest survivor absorbs closed-pane space on both axes, nested groups, floating windows')
