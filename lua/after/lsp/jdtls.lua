-- https://poe.com/chat/956upl568lvwke4h4l
local mason = vim.fn.stdpath("data") .. "/mason"

local bundles = {}

local function add_glob(pattern)
  local matches = vim.fn.glob(pattern, true, true)
  for _, match in ipairs(matches) do
    if match ~= "" then
      table.insert(bundles, match)
    end
  end
end

-- Current Mason layout
add_glob(mason .. "/share/java-debug-adapter/com.microsoft.java.debug.plugin-*.jar")

-- Older/alternate Mason layout
add_glob(mason .. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar")

-- Optional java-test bundles
add_glob(mason .. "/share/java-test/*.jar")
add_glob(mason .. "/packages/java-test/extension/server/*.jar")

bundles = vim.tbl_filter(function(jar)
  local name = vim.fn.fnamemodify(jar, ":t")

  return name ~= "com.microsoft.java.test.runner-jar-with-dependencies.jar"
    and name ~= "jacocoagent.jar"
end, bundles)

return {
  cmd = {
    mason .. "/bin/jdtls",
  },

  init_options = {
    bundles = bundles,
  },
}
