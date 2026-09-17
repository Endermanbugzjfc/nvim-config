-- https://poe.com/chat/956upl568lvwke4h4l

if vim.env.NVIM_ENABLE_JDTLS_DEBUGGER ~= "1" then
  do return end
end

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
    -- Heap: 27G total RAM / ~14G free -> 16G leaves headroom so we never swap
    -- (swapping is what actually causes lag; a bigger heap does not).
    "-Xms4g",
    "-Xmx16g",
    -- GC tuning to keep pauses short on a 24-core box.
    "-XX:+UseG1GC",
    "-XX:+UseStringDeduplication",
    "-XX:GCTimeRatio=4",
    "-XX:AdaptiveSizePolicyWeight=90",
    "-Dsun.zip.disableMemoryMapping=true",
  },

  init_options = {
    bundles = bundles,
  },

  settings = {
    java = {
      -- jdtls reads a project's .editorconfig automatically and applies it to
      -- both formatting AND generated code (getters/setters, constructors,
      -- toString, organize-imports, ...). Generated code is only run through the
      -- formatter when formatting is enabled, so keep it on. .editorconfig takes
      -- precedence over the settings below and over java.format.settings.url.
      format = {
        enabled = true,
      },
    },
  },
}
