local dap = require "dap"
local dapui = require "dapui"

dapui.setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

dap.adapters.codelldb = function(callback)
  local mason_packages = vim.fn.stdpath "data" .. "/mason/packages"
  local liblldb = mason_packages .. "/codelldb/extension/lldb/lib/liblldb.so"
  if vim.fn.filereadable(liblldb) == 0 then
    liblldb = vim.fn.exepath "lldb"
  end
  callback {
    type = "server",
    port = "${port}",
    executable = {
      command = vim.fn.exepath "codelldb",
      args = {
        "--liblldb", liblldb,
        "--port", "${port}",
      },
    },
  }
end

dap.configurations.cpp = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {},
  },
  {
    name = "Attach to process",
    type = "codelldb",
    request = "attach",
    pid = require("dap.utils").pick_process,
    cwd = "${workspaceFolder}",
  },
}

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

dap.adapters.python = {
  type = "executable",
  command = "debugpy-adapter",
}

dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    pythonPath = require("configs.venv").find_python,
  },
  {
    type = "python",
    request = "launch",
    name = "Launch with arguments",
    program = "${file}",
    args = function()
      local args_string = vim.fn.input("Arguments: ")
      return vim.split(args_string, " ")
    end,
    pythonPath = require("configs.venv").find_python,
  },
  {
    type = "python",
    request = "attach",
    name = "Attach to process",
    connect = {
      host = "127.0.0.1",
      port = 5678,
    },
  },
}

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpointRejected", linehl = "", numhl = "" })