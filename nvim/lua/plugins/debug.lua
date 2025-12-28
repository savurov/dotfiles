return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'jay-babu/mason-nvim-dap.nvim',
    'mfussenegger/nvim-dap-python',
    'theHamsta/nvim-dap-virtual-text',
  },

  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    -- Mason DAP
    require('mason-nvim-dap').setup {
      ensure_installed = { 'python' },
      automatic_installation = true,
      handlers = {}, -- пусто, чтобы не переопределялось
    }

    -- UI и виртуальные значения
    require('nvim-dap-virtual-text').setup { commented = true }
    dapui.setup()

    -- Автооткрытие/закрытие UI
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
    end

    -- Python DAP (использует debugpy)
    require('dap-python').setup 'uv'

    -- Конфигурации запуска
    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = 'Launch current file (src imports)',
        program = '${file}',
        pythonPath = vim.fn.exepath 'python3',
        cwd = vim.fn.getcwd(),
        justMyCode = false,
        console = 'integratedTerminal',
        env = { PYTHONPATH = vim.fn.getcwd() },
      },
      {
        type = 'python',
        request = 'launch',
        name = 'Launch module (python -m ...)',
        module = '${relativeFileDirname}',
        justMyCode = false,
        console = 'integratedTerminal',
        env = { PYTHONPATH = vim.fn.getcwd() },
      },
      {
        type = 'python',
        request = 'launch',
        name = 'Run pytest on current file',
        module = 'pytest',
        args = { '${file}' },
        justMyCode = false,
        console = 'integratedTerminal',
        env = { PYTHONPATH = vim.fn.getcwd() },
      },
    }
  end,
}
