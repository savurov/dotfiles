-- helper: принимает либо таблицу opts, либо просто строку-описание
local function map(mode, lhs, rhs, opt)
  local defaults = { noremap = true, silent = false }
  local options
  if type(opt) == 'string' then
    options = vim.tbl_extend('force', defaults, { desc = opt })
  elseif type(opt) == 'table' then
    options = vim.tbl_extend('force', defaults, opt)
  else
    options = defaults
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- ===== Общие =====
map('n', '<Esc>', '<cmd>nohlsearch<CR>', 'Clear search highlight')
map('n', '<C-h>', '<C-w><C-h>', 'Move focus left')
map('n', '<C-l>', '<C-w><C-l>', 'Move focus right')
map('n', '<C-j>', '<C-w><C-j>', 'Move focus down')
map('n', '<C-k>', '<C-w><C-k>', 'Move focus up')
map('v', '<C-c>', '"+y', 'ctrl+c')
map('n', '<leader>q', '<cmd>qa<CR>', 'Quit')

--====== Neo-tree  =====
map('n', '<leader>e', '<cmd>Neotree toggle<CR>', 'nEotree')

-- ===== Telescope =====
local tb = require 'telescope.builtin'
map('n', '<leader>sf', tb.find_files, '[s]earch [f]iles')
map('n', '<leader>sg', tb.live_grep, 'Live [g]rep')
map('n', '<leader>sb', tb.oldfiles, '[s]earch [b]ack')
map('n', '<leader>sr', tb.resume, '[s]earch [r]esume last search')

map('n', '<leader>sh', tb.help_tags, '[s]earch [h]elp')
map('n', '<leader>sk', tb.keymaps, '[s]earch [k]eymaps')
map('n', '<leader>sw', tb.grep_string, '[s]earch current [w]ord')
map('n', '<leader>sd', tb.diagnostics, '[s]earch [d]iagnostics')
map('n', '<leader><leader>', tb.find_files, 'space space')
map('n', '<leader>ss', tb.builtin, 'telescope functions')

map('n', '<leader>sn', function()
  tb.find_files { cwd = vim.fn.stdpath 'config' }
end, '[s]earch [n]eovim files')

map('n', '<leader>sc', function()
  tb.find_files { cwd = '~/.config' }
end, '[s]earch [c]onfig files')

-- ===== LSP =====
map('n', '<leader>h', vim.lsp.buf.hover, 'Hover info')
map('n', 'gd', vim.lsp.buf.definition, 'go to Definition')
map('n', '<leader>w', vim.diagnostic.open_float, 'show Warning')
map('n', 'gr', tb.lsp_references, 'go to References')
map('n', '<leader>r', vim.lsp.buf.rename, 'Rename')
map('n', '<leader>c', vim.lsp.buf.code_action, 'Code action')

-- Инсерт-комплишн (работает с nvim-cmp, а иначе пробует lsp.buf.completion)
map('i', '<C-Space>', function()
  local ok, cmp = pcall(require, 'cmp')
  if ok then
    cmp.complete()
  elseif vim.lsp.buf.completion then
    vim.lsp.buf.completion()
  end
end, 'completion')

map('n', '<leader>g', '<cmd>LazyGit<cr>', 'lazyGit')
map('n', '<leader>b', '<C-6>', { desc = 'back' })

-- ===== DAP ======
local dap = require 'dap'
local dapui = require 'dapui'

map('n', '<leader>dc', dap.continue, 'DAP: Continue')
map('n', '<leader>di', dap.step_into, 'DAP: step Into')
map('n', '<leader>do', dap.step_out, 'DAP: step Out')
map('n', '<leader>dv', dap.step_over, 'DAP: step oVer')
map('n', '<leader>db', dap.toggle_breakpoint, 'DAP: toggle Breakpoint')
map('n', '<leader>dB', function()
  dap.set_breakpoint(vim.fn.input 'Condition: ')
end, 'DAP: conditional Breakpoint')
map('n', '<leader>du', function()
  dapui.toggle()
end, 'DAP: Toggle [u]i')
map('n', '<leader>dr', dap.restart, 'DAP: Restart session')
map('n', '<leader>dq', dap.terminate, 'DAP: Quit')
