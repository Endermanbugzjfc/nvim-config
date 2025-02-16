return {
  'Bekaboo/dropbar.nvim', -- Symbols breadcrumb bar.
  -- optional, but required for fuzzy finder support
  dependencies = {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make'
  },
  config = true,
  event = "BufEnter",
}
