-- Run: XDG_STATE_HOME=/tmp/nvim-splitjoin-state NVIM_LOG_FILE=/tmp/nvim-splitjoin.log nvim -n --headless -u NONE -i NONE -l tests/mini_splitjoin.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/mini.nvim")
vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.comments = ""

local splitjoin = require "mini.splitjoin"
splitjoin.setup()
local function set(lines, cursor)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(0, cursor or { 1, 0 })
end
local function get() return vim.api.nvim_buf_get_lines(0, 0, -1, false) end
local function eq(actual, expected, label)
  assert(vim.deep_equal(actual, expected), (label or "unexpected edit") .. "\nexpected: "
    .. vim.inspect(expected) .. "\nactual: " .. vim.inspect(actual))
end

-- Compare the customized behavior to the installed plugin's actual defaults.
local cases = {
  { "f(a + b, c * d)" },
  { "[a + b, c * d]" },
  { "{ first = a + b, second = c * d }" },
  { "f(a < b, c > d, e)" },
  { [[f('a, b', "c d", {e, f}, [g, h], (i, j))]] },
  { "f(a + b)" },
  { "()" },
  { "[]" },
  { "{}" },
  { "a < b and c > d" },
  { "<div>text</div>" },
  { "</div>" },
  { "<!-- a b -->" },
}
local expected, expected_join = {}, {}
local function bracket_cursor(lines)
  return { 1, (lines[1]:find("[%(%[%{<]") or 1) - 1 }
end
for i, lines in ipairs(cases) do
  set(lines, bracket_cursor(lines))
  splitjoin.toggle()
  expected[i] = get()
  if #get() > 1 then
    splitjoin.toggle()
    expected_join[i] = get()
  end
end

require("configs.mini_splitjoin").setup()
for i, lines in ipairs(cases) do
  set(lines, bracket_cursor(lines))
  splitjoin.toggle()
  eq(get(), expected[i], "default behavior: " .. lines[1])
  if #get() > 1 then
    splitjoin.toggle()
    eq(get(), expected_join[i], "default join")
  end
end

local function roundtrip(source, expanded, joined, cursor)
  set({ source }, cursor)
  splitjoin.toggle()
  eq(get(), expanded, "HTML split: " .. source)
  splitjoin.toggle()
  eq(get(), { joined or source }, "HTML join: " .. source)
end

roundtrip('<div class="foo bar" id="x">text</div>', {
  "<div", '  class="foo bar"', '  id="x"', ">text</div>",
})
roundtrip("<input disabled type='text' />", {
  "<input", "  disabled", "  type='text'", "/>",
}, "<input disabled type='text'/>")
roundtrip([[<widget:item title="a > b < c, d" data-x='one two' values=a,b>]], {
  "<widget:item", [[  title="a > b < c, d"]], "  data-x='one two'", "  values=a,b", ">",
}, nil, { 1, 25 })
roundtrip('<div class = "foo bar"  hidden>', {
  "<div", '  class = "foo bar"', "  hidden", ">",
}, '<div class = "foo bar" hidden>')
roundtrip('<div id="x">', { "<div", '  id="x"', ">" }, nil, { 1, 10 })

-- The innermost ordinary brackets still win inside tag attributes.
set({ '<div title="f(a + b, c)">' }, { 1, 14 })
splitjoin.toggle()
eq(get(), { '<div title="f(', "  a + b,", "  c", ')">' }, "inner brackets")

-- HTML in an enclosing call should win when the cursor is on the tag.
set({ 'render(<div id="x">)' }, { 1, 8 })
splitjoin.toggle()
eq(get(), { "render(<div", '  id="x"', ">)" }, "nested HTML")

-- Direct API actions and explicit Visual-style regions use the same options.
set({ '<div id="x">' })
splitjoin.split({ region = { from = { line = 1, col = 1 }, to = { line = 1, col = 12 } } })
eq(get(), { "<div", '  id="x"', ">" }, "explicit region")
splitjoin.join()
eq(get(), { '<div id="x">' }, "direct join")

set({ '<div id="x">' })
vim.cmd "normal v$hgS"
eq(get(), { "<div", '  id="x"', ">" }, "Visual mapping")

set({ '<div id="x"', ">" })
splitjoin.toggle()
eq(get(), { '<div id="x">' }, "join closing bracket only")
set({ '<div id="x"', '  class="y">' })
splitjoin.toggle()
eq(get(), { '<div id="x" class="y">' }, "join attributes after first line")
set({ '<div', '  id="x">' })
splitjoin.toggle()
eq(get(), { '<div id="x">' }, "join attribute on closing bracket line")

set({ '<div id="x">' })
vim.b.minisplitjoin_disable = true
splitjoin.toggle()
eq(get(), { '<div id="x">' }, "disabled buffer")
vim.b.minisplitjoin_disable = nil

-- Exercise the actual operator mapping and its dot-repeat on another tag.
set({ '<div id="x">', '<span id="y">' })
vim.cmd "normal gS"
eq(get(), { "<div", '  id="x"', ">", '<span id="y">' }, "gS mapping")
vim.api.nvim_win_set_cursor(0, { 4, 0 })
vim.cmd "normal ."
eq(get(), { "<div", '  id="x"', ">", "<span", '  id="y"', ">" }, "dot-repeat")

print "PASS: default brackets, HTML attributes, nested regions, API calls, Normal/Visual gS and dot-repeat"
