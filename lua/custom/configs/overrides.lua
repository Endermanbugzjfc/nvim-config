local M = {}

M.treesitter = {
  ensure_installed = {
    "vim",
    "lua",
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "c",
    "markdown",
    "markdown_inline",
  },
  indent = {
    enable = true,
    -- disable = {
    --   "python"
    -- },
  },
}

M.mason = {
  ensure_installed = {
    -- lua stuff
    "lua-language-server",
    "stylua",

    -- web dev stuff
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "deno",
    "prettier",

    -- c/cpp stuff
    "clangd",
    "clang-format",

    "gopls",
    "intelephense",
    "rust-analyzer",
  },
}

-- git support in nvimtree
M.nvimtree = {
  git = {
    enable = true,
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
}

local cmp = require("cmp")
M.cmp = {
  completion = {
    completeopt = "menu,menuone,noselect,noinsert,preview", -- Important. (ec5cf0b)
  },
  mappings = {
    ["<C-CR>"] = cmp.mapping.confirm { -- Otherwise, cannot open a new line when completion popup is opened.
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "nvim_lua" },
    { name = "path" },
    { name = "cmp_tabnine" },
  },
}

M.telescope = {
  defaults = {
    -- prompt_prefix = " 揾笨 ",
    file_ignore_patterns = { "node_modules", ".git" },
  },
  extensions_list = { "themes", "terms", "ui-select" },
  extensions = {
    ["ui-select"] = {},
  },
  pickers = {
    find_files = {
      mappings = {
        n = {
          ["<M-h>"] = "select_horizontal",
          ["<M-v>"] = "select_vertical", -- <C-v> not working on Windows.
        },
      },
    },
  },
}

return M
