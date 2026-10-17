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

  {
    "3rd/image.nvim",
    lazy = false,
    build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      integrations = {
        markdown = { enabled = true },
      },
      max_width = nil,
      max_height = nil,
      scale_factor = 1.0,
    },
    config = function(_, opts)
      local image = require "image"
      local hijack_buffer = image.hijack_buffer
      image.hijack_buffer = function(path, ...)
        -- mini.files previews have image extensions but are virtual buffers,
        -- including previews of names that have not been created on disk yet.
        if vim.startswith(path, "minifiles://") then
          return
        end
        return hijack_buffer(path, ...)
      end
      image.setup(opts)
      require("python_images").setup()
    end,
  },

  {
    "SCJangra/table-nvim",
    ft = 'markdown',
    opts = {
      padd_column_separators = true,
      mappings = {
        next = '<TAB>',        -- Move to next cell
        prev = '<S-TAB>',      -- Move to previous cell
        insert_row_down = '<A-j>', -- Insert row below
        move_column_right = '<A-S-l>', -- Swap column layout right
      }
  },
}
}
