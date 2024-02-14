local overrides = require("custom.configs.overrides")

local data_path = vim.fn.stdpath("data")

-- https://github.com/codota/tabnine-nvim?tab=readme-ov-file#windows
-- Get platform dependant build script
local function tabnine_build_path()
  if vim.loop.os_uname().sysname == "Windows_NT" then
    return "PowerShell.exe -file .\\dl_binaries.ps1"
  else
    return "./dl_binaries.sh"
  end
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
    "codota/tabnine-nvim",
    build = tabnine_build_path(),
    event = "InsertEnter",
    config = function()
      require("tabnine").setup({
        disable_auto_comment = false,
        accept_keymap = "<C-CR>",
        dismiss_keymap = "<M-\\>",
        debounce_ms = 800,
        suggestion_color = { gui = "#008000", cterm = 1 },
        exclude_filetypes = {"TelescopePrompt", "NvimTree"},
        log_file_path = data_path .. "/tabnine.log" , -- absolute path to Tabnine log file
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
