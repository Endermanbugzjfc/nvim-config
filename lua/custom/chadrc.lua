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

  statusline = {
    theme = "vscode",
    overriden_modules = function (modules)
      local mode = ({
        ["NORMAL"] = "躺平",
        ["INSERT"] = "內卷",
        ["VISUAL"] = "割韭菜",
        ["REPLACE"] = "河蟹",
        ["V-BLOCK"] = "共產",
        ["COMMAND"] = "送中",
        ["TERMINAL"] = "國牆",
      })[string.match(modules[1], "%S+%s+%S+%s+(%S+)")]
      if mode ~= nil then
        modules[1] = "%#ST_Mode# " .. mode .. " "
      end
    end,
  },
  nvdash = {
    load_on_startup = true,
    header = {
      "        ██▄                                     ",
      "        ███          ██▄           ███          ",
      "        ███         ███            ███  ██▄     ",
      "        ███        ████████████    ███    ███   ",
      "  █████████████   ███      ███     ██           ",
      "        ███     ▄██▄ ██   ████████████████████  ",
      "        ███    ███     █████      ████          ",
      "        ███       █▄     ██      ███████        ",
      "        ███        ███████      ███  ███        ",
      "        ███████       ███      ███     ███      ",
      "    ████████        ███      ████       ████    ",
      "  ███   ███      ████     ▄████           ████  ",
      "        ███    ▄██       ███                ██  ",
      "        ███                             ▄█      ",
      "        ███       ███    ██     ███     ████    ",
      "        ███     ▄███     ███     ███      ███   ",
      "        ███    ███       ███      ███      ███  ",
      "   ▄██████    ███         ██                █▄  ",
    },
    buttons = {},
  },
}

M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require "custom.mappings"

return M
