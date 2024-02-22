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
    "grammarly-languageserver",
    "vim-language-server",
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
    preselect = cmp.PreselectMode.None,
    completeopt = "menu,menuone,noselect,noinsert,preview", -- Fixed first item unreachable.
  },
  mapping = {
    ["<CR>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = false, -- Otherwise, cannot open a new line when completion popup is opened.
    },
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "nvim_lua" },
    { name = "path" },
    { name = "cmp_tabnine" }, -- tzachar/cmp-tabnine
  },
}

M.telescope = {
  defaults = {
    file_ignore_patterns = { ".git" },
  },
  extensions = {
    themes = {},
    terms = {},
    attempt = {},
    ["ui-select"] = {},
  },
  pickers = {
    find_files = {
      mappings = {
        n = {
          ["<S-j>"] = "select_horizontal", -- Default <S-j>: join line.
          ["<S-l>"] = "select_vertical", -- Default <S-l>: last line on the window.
        },
        i = {
          ["<M-h>"] = "select_horizontal",
          ["<M-v>"] = "select_vertical",
        },
      },
    },
  },
}
local exts = {}
for ext, _ in pairs(M.telescope.extensions) do
  table.insert(exts, ext)
end
M.telescope.extensions_list = exts

M.gitsigns = {
  signs = {
    delete = { text = "" }, -- nf-fa-eraser
    change = { text = "▍" }, -- U+258D
    add = { text = "▎" }, -- U+258E
    untracked = { text = "▎" },
  },
}

return M
