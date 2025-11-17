return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = function()
      return require "configs.telescope"
    end,
  },
  {
      "hrsh7th/nvim-cmp",
    opts = function()
      return require "configs.nvim-cmp"
    end,
  },

  { "m-demare/attempt.nvim", config = true }, -- Scratch files.
}
