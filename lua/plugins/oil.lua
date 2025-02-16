return {
  'stevearc/oil.nvim', -- Editable-buffer files list.
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = { view_options = { show_hidden = true } },
  -- Optional dependencies
  -- dependencies = { { "echasnovski/mini.icons", opts = {} } },
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  config = true,
  cmd = { "Oil" }
}
