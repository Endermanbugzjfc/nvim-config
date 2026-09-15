return {
  {
    'mrcjkb/haskell-tools.nvim',
    version = '^4', -- Recommended version
    ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
    config = function()
      -- The plugin automatically configures itself and attaches to HLS
    end,
  }
}

