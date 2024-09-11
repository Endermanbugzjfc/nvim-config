local overrides = require("custom.configs.overrides")

local function GetTabnineBuildPath()
  if vim.loop.os_uname() == "Windows_NT" then
    return "powershell ./install.ps1"
  end
  return "./install.sh"
end

---@type NvPluginSpec[]
local plugins = {

  -- Override plugin definition options

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end, -- Override to setup mason-lspconfig
  },

  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },

  {
    "stevearc/conform.nvim",
    --  for users those who want auto-save conform + lazyloading!
    -- event = "BufWritePre"
    config = function()
      require "custom.configs.conform"
    end,
  },

  { "m-demare/attempt.nvim", config = true },

  {
    "echasnovski/mini.nvim", -- The "Swiss Army knife".
    event = "BufEnter",
    version = '*',
    config  = function()
        require("mini.cursorword").setup()
        require("mini.jump").setup(--[[ { mappings = { repeat_jump = "-" } } ]])
        require("mini.jump2d").setup() -- Key: <CR>
      -- mini.map: distraction.
      -- mini.move: mistrigger-prone.
        require("mini.splitjoin").setup() -- Key: gS
        require("mini.surround").setup() -- Key: s+prefix
        require("mini.trailspace").setup()
    end,
  },

  { "tpope/vim-sleuth", event = "BufEnter" }, -- Tab width adaptation.

  {
    "tpope/vim-abolish", -- Advanced substitute.
    event = "BufEnter",
    dependencies = { "markonm/traces.vim", event = "BufEnter" },
  },

  { "nvim-telescope/telescope-ui-select.nvim" }, -- UI for LSP code action.

  {
    "tzachar/cmp-tabnine",
    event = "InsertEnter",
    build = GetTabnineBuildPath(),
    dependencies = "hrsh7th/nvim-cmp",
    config = function()
      local tabnine = require('cmp_tabnine.config')
      tabnine:setup({ -- Use colon instead of period.
        max_lines = 1000,
        max_num_results = 20,
        sort = true,
        run_on_every_keystroke = true,
        snippet_placeholder = '..',
        ignored_file_types = {
          -- default is not to ignore
          -- uncomment to ignore in lua:
          -- lua = true
        },
        show_prediction_strength = false,
        min_percent = 0
      })

      local prefetch = vim.api.nvim_create_augroup("prefetch", {clear = true})
      vim.api.nvim_create_autocmd('BufRead', {
        group = prefetch,
        -- pattern = '*.py',
        callback = function()
          require('cmp_tabnine'):prefetch(vim.fn.expand('%:p'))
        end
      })
    end,
  },

  -- {
  --   "sindrets/diffview.nvim",
  --   cmd = {
  --     "DiffviewOpen",
  --     "DiffviewClose",
  --     "DiffviewToggleFiles",
  --     "DiffviewFocusFiles",
  --     "DiffviewRefresh",
  --     "DiffviewFileHistory",
  --   },
  --   config = true,
  -- },
  --
  -- {
  --   "stevearc/oil.nvim",
  --   cmd = "Oil",
  --   config = true,
  -- },
  --
  -- {
  --   "iamcco/markdown-preview.nvim",
  --   cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  --   ft = { "markdown" },
  --   build = function() vim.fn["mkdp#util#install"]() end,
  -- },

  -- To make a plugin not be loaded
  -- {
  --   "NvChad/nvim-colorizer.lua",
  --   enabled = false
  -- },

  -- All NvChad plugins are lazy-loaded by default
  -- For a plugin to be loaded, you will need to set either `ft`, `cmd`, `keys`, `event`, or set `lazy = false`
  -- If you want a plugin to load on startup, add `lazy = false` to a plugin spec, for example
  -- {
  --   "mg979/vim-visual-multi",
  --   lazy = false,
  -- }
}

for alias, plugin in pairs({
    mason = "williamboman/mason.nvim",
    treesitter = "nvim-treesitter/nvim-treesitter",
    nvimtree = "nvim-tree/nvim-tree.lua",
    cmp = "hrsh7th/nvim-cmp",
    telescope = "nvim-telescope/telescope.nvim",
    gitsigns = "lewis6991/gitsigns.nvim",
}) do
  table.insert(plugins, { plugin, opts = overrides[alias] })
end

return plugins
