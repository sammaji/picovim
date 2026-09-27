return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "leoluz/nvim-dap-go",
    {
      "rcarriga/nvim-dap-ui",
      dependencies = { "nvim-neotest/nvim-nio" },
    },
    "theHamsta/nvim-dap-virtual-text",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    require("dap-go").setup()
    dapui.setup()
    require("nvim-dap-virtual-text").setup()

    -- `make dev DEBUG=1` builds bifrost-http with -N -l and runs it inside a
    -- headless dlv on 127.0.0.1:2345 (see transports/bifrost-http/.air.debug.toml).
    -- Attach to that instead of launching a second copy of the binary.
    table.insert(dap.configurations.go, 1, {
      type = "go",
      name = "Attach to bifrost-http (dlv :2345)",
      request = "attach",
      mode = "remote",
      host = "127.0.0.1",
      port = 2345,
    })

    -- auto open/close the UI when a debug session starts/ends
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end
  end,
  keys = {
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
    {
      "<leader>dB",
      function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end,
      desc = "Debug: Conditional Breakpoint",
    },
    { "<leader>dc", function() require("dap").continue() end, desc = "Debug: Continue / Start" },
    { "<leader>di", function() require("dap").step_into() end, desc = "Debug: Step Into" },
    { "<leader>do", function() require("dap").step_over() end, desc = "Debug: Step Over" },
    { "<leader>dO", function() require("dap").step_out() end, desc = "Debug: Step Out" },
    { "<leader>dr", function() require("dap").repl.open() end, desc = "Debug: Open REPL" },
    { "<leader>dl", function() require("dap").run_last() end, desc = "Debug: Run Last" },
    { "<leader>dt", function() require("dap").terminate() end, desc = "Debug: Terminate" },
    { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
    {
      "<leader>dh",
      function() require("dap.ui.widgets").hover() end,
      desc = "Debug: Hover Variable",
    },
  },
}
