-- This file contains more theme definitions besides chadrc.lua but these are not changed often,
-- which should be  less dirty in terms of Git.

-- These have been extracted from options.lua as they weren't supposed to be there, but I didn't
-- want to touch code when they work fine:

-- Quicklist pick line:
-- Define the sign once
vim.fn.sign_define("QFMarker", { text = "", texthl = "DiagnosticInfo" })

-- https://poe.com/chat/956upl568lvwke4h4l
-- Debugging:
vim.fn.sign_define("DapBreakpoint", {
  text = "●",
  texthl = "DiagnosticSignError",
  linehl = "",
  numhl = "",
})

vim.fn.sign_define("DapBreakpointCondition", {
  text = "◆",
  texthl = "DiagnosticSignWarn",
  linehl = "",
  numhl = "",
})

vim.fn.sign_define("DapStopped", {
  text = "→",
  texthl = "DiagnosticSignInfo",
  linehl = "Visual",
  numhl = "DiagnosticSignInfo",
})

