return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    triggers = { -- https://www.reddit.com/r/neovim/comments/1e5y9qt/comment/ldqt8wg
      { "<auto>", mode = "nixsotc" },
      { "s", mode = { "n", "v" } },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
