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

  -- override plugin configs
  {
    "williamboman/mason.nvim",
    opts = overrides.mason
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  {
    "hrsh7th/nvim-cmp",
    opts = overrides.cmp,
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = overrides.telescope,
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

  {
    "m-demare/attempt.nvim", -- Scratch files manager.
    dependencies = {"nvim-lua/plenary.nvim" },
    config = function()
      require("attempt").setup()
      require("telescope").load_extension "attempt"
    end,
  },

  -- {
  --   "ggandor/leap.nvim", -- Fast navigation within visible area.
  --   event = "BufEnter",
  --   dependencies = {
  --     "tpope/vim-repeat",
  --   },
  --   config = function()
  --     require("leap").add_default_mappings()
  --   end,
  -- },

  {
    "echasnovski/mini.nvim", -- The "Swiss Army knife".
    event = "BufEnter",
    version = '*',
    config  = function()
        require("mini.cursorword").setup()
        -- require("mini.jump").setup({ mappings = { repeat_jump = "-" } })
        require("mini.jump").setup()
        require("mini.jump2d").setup() -- Key: <CR>
        -- require("mini.map").setup()
        -- require("mini.move").setup()
        -- require("mini.sessions").setup()
        require("mini.splitjoin").setup() -- Key: gS
        require("mini.surround").setup() -- Key: s+prefix
        require("mini.trailspace").setup()
    end,
  },

  { "tpope/vim-sleuth", event = "BufEnter" }, -- Tab width adaptation.
  { "yorickpeterse/nvim-window" }, -- Jump between windows.

  {
    "tpope/vim-abolish", -- Advanced substitute.
    event = "BufEnter",
    dependencies = { "markonm/traces.vim", event = "BufEnter" },
  },

  {
    "nvim-telescope/telescope-ui-select.nvim", -- UI for LSP code action.
    config = function()
      require("telescope").load_extension "ui-select"
    end,
  },

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

  -- { "haya14busa/incsearch.vim" },

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

return plugins
