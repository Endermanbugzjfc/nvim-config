return {
  "echasnovski/mini.nvim", -- The "Swiss Army knife".
  event = "BufEnter",
  version = '*',
  config  = function()
    require("mini.cursorword").setup()
    require("mini.jump").setup(--[[ { mappings = { repeat_jump = "-" } } ]])
    require("mini.jump2d").setup({
      mappings = {
        start_jumping = "<leader><leader>",
      },
    })
    -- https://github.com/echasnovski/mini.jump2d/blob/3de91ea974627c4c2645e288bf0a6e6717a4dfa8/lua/mini/jump2d.lua#L121C8-L121C69
    vim.api.nvim_set_hl(0, 'MiniJump2dSpot', { reverse = true })

    require("mini.map").setup {
      window = {
        focusable = true,
        width = 5,
      },
    }
    require("mini.map").open()

    require("mini.splitjoin").setup() -- Key: gS
    require("mini.surround").setup() -- Key: s+prefix
    require("mini.trailspace").setup()
  end,
}
