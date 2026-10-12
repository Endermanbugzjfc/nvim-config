local luasnip = require "luasnip"
local snippet = luasnip.snippet
local t = luasnip.text_node
local i = luasnip.insert_node

return {
  snippet({ trig = "image", desc = "Inline image.nvim image declaration" }, {
    t "# image.nvim: path=",
    i(1, "./assets/model.png"),
    t " width=",
    i(2, "40"),
    t " height=",
    i(3, "20"),
    i(0),
  }),
}
