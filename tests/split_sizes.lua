-- Run: NVIM_LOG_FILE=/tmp/nvim-split-sizes.log nvim --headless -n -u NONE -i NONE -l tests/split_sizes.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.o.lines = 60
vim.o.columns = 160
require('configs.split_sizes').setup()

local function resized()
  vim.api.nvim_exec_autocmds('WinResized', {})
end

local function command(line)
  vim.api.nvim_feedkeys(':' .. line .. '\r', 'xt', false)
  resized()
end

local function eq(actual, expected, message)
  assert(actual == expected, message .. ': expected ' .. expected .. ', got ' .. actual)
end

-- Only a resize in a stable layout should become the next split's size.
command('split')
vim.cmd('resize 8')
resized()
command('close')
command('split')
eq(vim.api.nvim_win_get_height(0), 8, 'horizontal size is restored')
command('close')

command('vsplit')
vim.cmd('vertical resize 31')
resized()
command('close')
command('vs')
eq(vim.api.nvim_win_get_width(0), 31, 'vertical size is restored')
command('close')

-- Restoring one dimension must not overwrite the other dimension's memory.
command('belowright sp')
eq(vim.api.nvim_win_get_height(0), 8, 'abbreviations and modifiers work')
command('close')
command('vertical split')
eq(vim.api.nvim_win_get_width(0), 31, 'vertical modifier uses width')
command('close')

-- Explicit counts override the remembered defaults.
command('12split')
eq(vim.api.nvim_win_get_height(0), 12, 'explicit height wins')
command('close')
command('45vsplit')
eq(vim.api.nvim_win_get_width(0), 45, 'explicit width wins')
command('close')

-- Terminal changes and floating windows must not replace remembered dimensions.
vim.o.columns = 180
vim.o.lines = 70
resized()
local float = vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, {
  relative = 'editor', row = 1, col = 1, width = 15, height = 4,
})
resized()
vim.api.nvim_win_set_width(float, 20)
resized()
vim.api.nvim_win_close(float, true)
resized()
command('split')
eq(vim.api.nvim_win_get_height(0), 8, 'terminal and floating changes preserve height')
command('close')
command('vsplit')
eq(vim.api.nvim_win_get_width(0), 31, 'terminal and floating changes preserve width')
command('close')

local file = vim.fn.tempname()
vim.fn.writefile({ 'first', 'second' }, file)
command('silent belowright split +2 ' .. vim.fn.fnameescape(file))
eq(vim.api.nvim_win_get_height(0), 8, 'file split uses remembered height')
eq(vim.api.nvim_buf_get_name(0), file, 'file argument is preserved')
eq(vim.api.nvim_win_get_cursor(0)[1], 2, '+command is preserved')
command('close')

-- A moved pane keeps its dimension, and changes orientation using size memory.
command('split')
local moved = vim.api.nvim_get_current_win()
command('wincmd J')
eq(vim.api.nvim_get_current_win(), moved, 'moving preserves the active pane')
eq(vim.api.nvim_win_get_height(0), 8, 'moving to the bottom preserves height')
command('wincmd K')
eq(vim.api.nvim_win_get_height(0), 8, 'moving to the top preserves height')
command('wincmd L')
eq(vim.api.nvim_win_get_width(0), 31, 'changing to vertical uses remembered width')
command('wincmd H')
eq(vim.api.nvim_win_get_width(0), 31, 'moving to the left preserves width')
command('wincmd H')
eq(vim.api.nvim_win_get_width(0), 31, 'moving to the same edge preserves width')
vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-w>L', true, false, true), 'xt', false)
resized()
eq(vim.api.nvim_win_get_width(0), 31, 'normal-mode pane movement preserves width')
command('wincmd J')
eq(vim.api.nvim_win_get_height(0), 8, 'changing to horizontal uses remembered height')
command('close')

-- Peer panes should retain their own sizes during rotations and exchanges.
command('vsplit')
command('vsplit')
vim.cmd('vertical resize 23')
resized()
local widths = {}
for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
  widths[win] = vim.api.nvim_win_get_width(win)
end
local function check_widths(message)
  for win, width in pairs(widths) do
    eq(vim.api.nvim_win_get_width(win), width, message .. ' (pane ' .. win .. ')')
  end
end
command('wincmd r')
check_widths('rotation preserves every pane width')
command('wincmd x')
check_widths('exchange preserves every pane width')
command('wincmd L')
check_widths('moving a pane preserves peer widths')
command('only')
command('vsplit')
eq(vim.api.nvim_win_get_width(0), 23, 'rearrangements do not overwrite size memory')
command('close')

print('PASS: split size memory, pane moves, rotations, exchanges, explicit counts, terminal/floating changes, file arguments')
