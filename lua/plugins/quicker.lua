return {
  {
    "stevearc/quicker.nvim",
    event = "FileType qf",
    opts = {
      edit = {
        enabled = true,
        autosave = "unmodified", -- auto-write files that had no unsaved changes
      },
      -- Set options explicitly so quicker does not reapply its default nowrap.
      use_default_opts = false,
      opts = {
        buflisted = false,
        number = false,
        relativenumber = false,
        signcolumn = "auto",
        winfixheight = true,
      },
    },
    keys = {
      { "<leader>co", function() require("quicker").toggle() end, desc = "Toggle quickfix" },
      { ">", function() require("quicker").expand({ before = 2, after = 2, add_to_existing = true }) end, desc = "Expand qf context" },
      { "<", function() require("quicker").collapse() end, desc = "Collapse qf context" },
    },
  },
}
