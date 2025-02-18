return { -- Advanced substitute.
  "tpope/vim-abolish",
  event = "BufEnter",
  dependencies = { "markonm/traces.vim", event = "BufEnter" },
  config = function ()
    vim.g.traces_abolish_integration = 1
  end
}
