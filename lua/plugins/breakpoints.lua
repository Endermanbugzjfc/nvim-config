return { -- Persistent DAP breakpoints manager.
  "Weissle/persistent-breakpoints.nvim",
  dependencies = { "mfussenegger/nvim-dap" },
  event = "BufReadPost",
  opts = {
    save_dir = "./",
    load_breakpoints_event = "BufReadPost",
  },
  config = true,
}
