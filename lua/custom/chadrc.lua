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
        ["V-BLOCK"] = "誅九族",
        ["V-LINE"] = "抄家",
        ["COMMAND"] = "送中",
        ["TERMINAL"] = "翻牆",
        ["NTERMINAL"] = "潤",
      })[string.match(modules[1], "%S+%s+%S+%s+(%S+)")]
      if mode ~= nil then
        modules[1] = "%#ST_Mode# " .. mode .. " "
      end
    end,
  },
  nvdash = {
    load_on_startup = true,
    header = {
      "     ████████▄      █████           ███████         ",
      " 香  ███████       ▄██████          ██████ ████     ",
      "     ██████        █████    ▄████   ██████   ██████ ",
      " 港  ██████        ████     ██████  █████    █████  ",
      "     ██████▄▄██   █████    ▄█████   █████           ",
      "█████████████████ ███ ███████████   █████   ██████  ",
      "     ██████      ███   ████████████████████████████ ",
      "     ██████     ███▄      ██████   █████  █         ",
      "     ██████     █  █████ ██████    █████  ██        ",
      "     ██████         ████▄█████    █████   ███       ",
      "     ████████████      █████     █████    ████      ",
      "█████████████         █████     ████       █████    ",
      " ██████████         ████       ████        ████████ ",
      "  ██ ██████       ████       ███            ██████  ",
      "     ██████     ███         █                ███    ",
      "     ██████         █              ██      ██       ",
      "     ██████        ██     ████      ████    █████▄  ",
      "     ██████     ▄████     █████     ██████   ██加███",
      "  █████████  ████████     █████     ██████    ██油██",
      "    ██████   ███████      ████      ████       ████ ",
      "                                                    ",
      "             光 復 香 港    時 代 革 命             ",
    },
    buttons = {},
  },
}

M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require "custom.mappings"

return M
