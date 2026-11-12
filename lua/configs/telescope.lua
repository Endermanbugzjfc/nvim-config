local function literal_parentheses(prompt)
  local result = {}
  local escaped = false
  local in_class = false

  for i = 1, #prompt do
    local char = prompt:sub(i, i)
    if escaped then
      escaped = false
    elseif char == "\\" then
      escaped = true
    elseif char == "[" and not in_class then
      in_class = true
    elseif char == "]" and in_class then
      in_class = false
    elseif (char == "(" or char == ")") and not in_class then
      result[#result + 1] = "\\"
    end
    result[#result + 1] = char
  end

  return table.concat(result)
end

local options = {
  defaults = {
    layout_config = {
      width = 0.99,
      horizontal = {
        preview_cutoff = 0, -- https://github.com/nvim-telescope/telescope.nvim/issues/1594#issuecomment-993447528
      },
    },
  },
  pickers = {
    live_grep = {
      on_input_filter_cb = function(prompt)
        return { prompt = literal_parentheses(prompt) }
      end,
    },
  },
}
return vim.tbl_deep_extend("force", require("nvchad.configs.telescope"), options)
