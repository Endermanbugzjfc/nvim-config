return {
  {
    'mrcjkb/haskell-tools.nvim',
    version = '^4', -- Recommended version
    ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
    dependencies = { 'mfussenegger/nvim-dap' },
    init = function()
      vim.g.haskell_tools = vim.tbl_deep_extend('force', vim.g.haskell_tools or {}, {
        dap = {
          -- Supplied by the project's devshell (along with ghci-dap).
          cmd = { 'haskell-debug-adapter' },
          auto_discover = true,
        },
      })
    end,
    config = function()
      require('configs.haskell-dap')
    end,
  }
}

