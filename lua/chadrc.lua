-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "darcula-dark",
  theme_toggle = { "github_light", "darcula-dark" },
	hl_override = {
		-- Comment = { italic = true },
		-- ["@comment"] = { italic = true },
    MatchWord = {
      -- bg = "#DDDDDD",
      italic = true,
      bold = true,
      bg = "none",
    },
	},
}

M.nvdash = { load_on_startup = true }
M.ui = {
--       tabufline = {
--          lazyload = false
--      },
  cmp = {
    style = "atom_colored",
  },
}

return M
