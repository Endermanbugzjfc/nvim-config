return { -- Debugger UI.
  "rcarriga/nvim-dap-ui",
  dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
  event = "BufEnter", -- For persistent breakpoints to load automatically.
  config = function()
    require("configs.java.java-dap")

    local dap, dapui = require("dap"), require("dapui")
    dapui.setup({
      controls = {
        enabled = true,
        element = "repl", -- required for java debugger
      },
    })
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.after.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.after.event_exited.dapui_config = function()
      dapui.close()
    end
  end,
}
