local cmp = require "cmp"
local options = {
  mapping = {
    ["<BS>"] = function (fallback)
      local resume = cmp.suspend()
      vim.schedule(resume)
      fallback()
    end
  }
}
return vim.tbl_deep_extend("force", require("nvchad.configs.cmp"), options)
