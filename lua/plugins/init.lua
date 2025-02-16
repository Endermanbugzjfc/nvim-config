return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  { "m-demare/attempt.nvim", config = true }, -- Scratch files.
}
