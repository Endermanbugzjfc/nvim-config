-- Run: NVIM_LOG_FILE=/tmp/nvim-paste.log nvim -n --headless -u NONE -i NONE '+luafile tests/paste.lua'
vim.opt.runtimepath:prepend(vim.fn.getcwd())
require("configs.paste").setup()

local function eq(actual, expected, label)
  assert(vim.deep_equal(actual, expected), label .. "\nexpected: " .. vim.inspect(expected)
    .. "\nactual: " .. vim.inspect(actual))
end

local function reset()
  vim.cmd("enew!")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "[]" })
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

local function selected(expected, label)
  vim.cmd('normal gV"zy')
  eq(vim.fn.getreg("z"), expected, label)
end

local function normal_tests()
  for _, command in ipairs({ "p", "P", "gp", "gP" }) do
    reset()
    vim.fn.setreg("a", "pasted", "v")
    vim.cmd('normal! "a2' .. command)
    selected("pastedpasted", "counted named-register " .. command)
  end

  reset()
  vim.fn.setreg("a", { "one", "two" }, "V")
  vim.cmd('normal! "ap')
  selected("one\ntwo", "linewise put")

  reset()
  vim.api.nvim_paste("one\nαβ", false, -1)
  selected("one\nαβ", "normal-mode bracketed paste")

  reset()
  vim.api.nvim_paste("one", false, 1)
  vim.api.nvim_paste("\ntwo", false, 2)
  vim.api.nvim_paste("", false, 3)
  selected("one\ntwo", "normal-mode chunked bracketed paste")
end

-- Let real input enter/leave Insert mode, so InsertLeave runs as it does in a terminal.
local function later(fn)
  vim.defer_fn(function()
    local ok, err = pcall(fn)
    if not ok then
      io.stderr:write(tostring(err) .. "\n")
      vim.cmd("cquit 1")
    end
  end, 10)
end

normal_tests()
reset()
vim.api.nvim_input("iBEFORE")
later(function()
  eq(vim.fn.mode(), "i", "insert-mode setup")
  vim.api.nvim_paste("first", false, -1)
  vim.api.nvim_input("BETWEEN")
  later(function()
    vim.api.nvim_paste("one", false, 1)
    vim.api.nvim_paste("\nαβ", false, 2)
    vim.api.nvim_paste("", false, 3)
    vim.api.nvim_input("AFTER<Esc>")
    later(function()
      selected("one\nαβ", "latest streamed paste excludes surrounding insertions")
      reset()
      vim.api.nvim_input("iBEFORE")
      later(function()
        vim.api.nvim_paste("PASTE", false, -1)
        vim.api.nvim_input("AFTER<Esc>")
        later(function()
          selected("PASTE", "single-call insert-mode paste")
          -- Restored marks must not interfere with a later ordinary put.
          vim.fn.setreg("a", "NEW", "v")
          vim.cmd('normal! "ap')
          selected("NEW", "ordinary put after bracketed paste")
          print("PASS: gV for register puts and normal/insert bracketed pastes, including chunks")
          vim.cmd("qa!")
        end)
      end)
    end)
  end)
end)
