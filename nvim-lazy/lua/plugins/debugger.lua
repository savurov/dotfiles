return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")

      require("dapui").setup({})
      local dapui = require("dapui")

      require("nvim-dap-virtual-text").setup({
        commented = true, -- Show virtual text alongside comment
      })

      dap.adapters.python = {
        type = "executable",
        command = vim.loop.fs_stat("./.venv/bin/python") and "./.venv/bin/python" or "python3",
        args = { "-m", "debugpy.adapter" },
      }

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch current file",
          program = "${file}",
          cwd = "${workspaceFolder}",
          pythonPath = function()
            local venv = vim.fn.getcwd() .. "/.venv/bin/python"
            if vim.fn.executable(venv) == 1 then
              return venv
            else
              return "python3"
            end
          end,
          console = "integratedTerminal",
          justMyCode = false,
        },
        {
          type = "python",
          request = "launch",
          name = "uvicorn /src/main.py (Debug)",
          module = "uvicorn",
          args = { "src.main:app", "--host", "127.0.0.1", "--port", "8000" },
          cwd = "${workspaceFolder}",
          env = {
            PYTHONPATH = "${workspaceFolder}",
          },
          pythonPath = "${workspaceFolder}/.venv/bin/python",
          console = "integratedTerminal", -- Optional: Use Neovim's terminal for output
          justMyCode = false, -- Optional: Debug into dependencies if needed
        },
        -- 🔹 Run pytest on the current file
        {
          type = "python",
          request = "launch",
          name = "Pytest: Current File",
          module = "pytest",
          cwd = "${workspaceFolder}",
          args = { "-q", "${file}" }, -- add "-vv" if you want more verbosity
          justMyCode = false,
          env = { PYTHONPATH = "${workspaceFolder}" },
          pythonPath = "${workspaceFolder}/.venv/bin/python",
        },
      }

      vim.fn.sign_define("DapBreakpoint", {
        text = "",
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapBreakpointRejected", {
        text = "", -- or "❌"
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapStopped", {
        text = "", -- or "→"
        texthl = "DiagnosticSignWarn",
        linehl = "Visual",
        numhl = "DiagnosticSignWarn",
      })

      local opts = { noremap = true, silent = true }
      local function map_opts(desc)
        return { noremap = true, silent = true, desc = desc }
      end

      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, map_opts("toggle breakpoint"))
      vim.keymap.set("n", "<leader>dc", dap.continue, map_opts("continue"))
      vim.keymap.set("n", "<leader>do", dap.step_over, map_opts("step over"))
      vim.keymap.set("n", "<leader>di", dap.step_into, map_opts("step into"))
      vim.keymap.set("n", "<leader>dO", dap.step_out, map_opts("step out"))
      vim.keymap.set("n", "<leader>dq", dap.terminate, map_opts("terminate"))
      vim.keymap.set("n", "<leader>du", dapui.toggle, map_opts("toggle ui"))

      -- Automatically open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
    end,
  },
}
