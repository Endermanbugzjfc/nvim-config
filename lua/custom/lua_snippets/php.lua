local luasnip = require("luasnip")
local snippet = luasnip.snippet
local t = luasnip.text_node
local i = luasnip.insert_node

-- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#lua
return {
  snippet({trig = "G", desc = "await-generator return type"}, {
    t"\\Generator<mixed, mixed, mixed, ", i(1, "void"), t">",
  }),
}
