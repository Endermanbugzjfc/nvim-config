local options = {
  defaults = {
    layout_config = {
      width = 0.99,
      horizontal = {
        preview_cutoff = 0, -- https://github.com/nvim-telescope/telescope.nvim/issues/1594#issuecomment-993447528
      }
    }
  }
}
return vim.tbl_deep_extend("force", require("nvchad.configs.telescope"), options)
