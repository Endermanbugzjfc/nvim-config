---@type ChadrcConfig
local M = {}
-- Path to overriding theme and highlights files
local highlights = require "custom.highlights"

M.ui = {
  theme = "github_light",
  theme_toggle = { "github_light", "github_light" },

  hl_override = highlights.override,
  hl_add = highlights.add,
  transparency =  true,
  tabufline = { enabled = false },

  statusline = require("custom.statusline"),
  nvdash = require("custom.dashboard"),
}

M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require "custom.mappings"

return M
