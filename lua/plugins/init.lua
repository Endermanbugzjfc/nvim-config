return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  { "m-demare/attempt.nvim", config = true }, -- Scratch files.
  { "Weissle/persistent-breakpoints.nvim", config = true } -- Cross-session breakpoints manager for DAP.
}
