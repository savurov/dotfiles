return {
  'nvim-telescope/telescope.nvim',
  -- можно оставить tag, но я предпочитаю ветку main без пина:
  -- tag = "0.1.8",
  event = 'VimEnter',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- turbo sorter
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  opts = function()
    local actions = require 'telescope.actions'
    local action_state = require 'telescope.actions.state'
    local builtin = require 'telescope.builtin'

    local find_files_no_ignore = function()
      local line = action_state.get_current_line()
      builtin.find_files { no_ignore = true, default_text = line }
    end

    local find_files_with_hidden = function()
      local line = action_state.get_current_line()
      builtin.find_files { hidden = true, default_text = line }
    end

    return {
      defaults = {
        sorting_strategy = 'ascending',
        layout_config = { prompt_position = 'top' },
        path_display = { 'smart' },
        file_ignore_patterns = { '%.git/', 'node_modules/', '__pycache__/' },
        mappings = {
          i = {
            ['<A-h>'] = find_files_with_hidden,
            ['<A-i>'] = find_files_no_ignore,
            ['<C-Down>'] = actions.cycle_history_next,
            ['<C-Up>'] = actions.cycle_history_prev,
            -- подсказки клавиш внутри пикера (как советует kickstarter)
            ['<C-/>'] = 'which_key',
          },
          n = { ['q'] = actions.close, ['?'] = 'which_key' },
        },
      },
      pickers = {
        buffers = {
          sort_mru = true,
          ignore_current_buffer = true,
        },
        help_tags = {
          mappings = {
            i = {
              ['<CR>'] = 'file_vsplit', -- to open help in vertical tab not horizontal
            },
          },
        },
      },
      extensions = {
        ['ui-select'] = require('telescope.themes').get_dropdown(),
      },
    }
  end,
  config = function(_, opts)
    require('telescope').setup(opts)
    -- безопасно грузим экстеншены, если установлены
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')
  end,
}
