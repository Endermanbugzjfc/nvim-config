local dap = require("dap")

dap.adapters.java = function(callback, _)
  local clients = vim.lsp.get_clients({
    bufnr = 0,
    name = "jdtls",
  })

  if #clients == 0 then
    vim.notify("No active jdtls client found. Open a Java file in a project first.", vim.log.levels.ERROR)
    return
  end

  local client = clients[1]

  client:request("workspace/executeCommand", {
    command = "vscode.java.startDebugSession",
  }, function(err, port)
    if err then
      vim.notify("Failed to start Java debug session: " .. vim.inspect(err), vim.log.levels.ERROR)
      return
    end

    callback({
      type = "server",
      host = "127.0.0.1",
      port = port,
    })
  end, 0)
end

dap.configurations.java = {
  -- {
  --   type = "java",
  --   request = "launch",
  --   name = "Launch Java Main",
  --
  --   mainClass = function()
  --     return vim.fn.input("Main class (FQCN): ")
  --   end,
  --
  --   projectName = function()
  --     local root = vim.fs.root(0, {
  --       ".git",
  --       "mvnw",
  --       "gradlew",
  --       "pom.xml",
  --       "build.gradle",
  --       "build.gradle.kts",
  --     })
  --
  --     return vim.fn.input(
  --       "Project name: ",
  --       root and vim.fn.fnamemodify(root, ":t") or vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  --     )
  --   end,
  --
  --   classPaths = { "$Auto" },
  --   modulePaths = { "$Auto" },
  --
  --   cwd = "${workspaceFolder}",
  -- },

  {
    type = "java",
    request = "attach",
    name = "Attach to remote JVM",
    hostName = "127.0.0.1",
    port = 5005,
  },
}
