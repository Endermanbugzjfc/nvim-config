return {
  theme = "vscode",
  overriden_modules = function (modules)
    modules[10] = "" -- Encoding
    modules[11] = "" -- Syntax
    modules[12] = "" -- LSP
    modules[13] = "" -- Folder

    -- https://github.com/NvChad/ui/blob/v2.0/lua/nvchad/statusline/vscode.lua
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
      -- %#ST_Mode# turns on text background.
      modules[1] = "%#ST_Mode# " .. mode .. " "
    end

    local buffer = vim.api.nvim_get_current_buf()
    local format = vim.api.nvim_buf_get_option(buffer, "fileformat")
    if format == "unix" then
      modules[13] = "LF"
    elseif format == "dos" then
      -- modules[13] = "󰰍󰈌"
      modules[13] = "CRLF"
    elseif format == "mac" then
      modules[13] = "CR"
    else
      modules[13] = "DLLM"
    end
  end,
}
