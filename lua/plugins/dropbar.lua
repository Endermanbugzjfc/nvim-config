return { -- Symbols breadcrumb bar.
  'Bekaboo/dropbar.nvim',
  dependencies = { -- optional, but required for fuzzy finder support
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make'
  },
  config = true,
  event = "BufEnter",
}
