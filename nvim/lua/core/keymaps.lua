-- helper: принимает либо таблицу opts, либо просто строку-описание
local function map(mode, lhs, rhs, opt)
  local defaults = { noremap = true, silent = true }
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

-- Neo-tree: надёжный toggle через API
map('n', '<leader>e', function()
  require('neo-tree.command').execute { toggle = true }
end, 'Toggle Neo-tree')

-- Копировать в системный буфер в визуальном режиме
map('v', '<C-c>', '"+y', 'Copy to system clipboard')

-- Quit
map('n', '<leader>q', '<cmd>q<CR>', 'Quit')

-- ===== LSP =====
map('n', 'K', vim.lsp.buf.hover, 'Hover info')
map('n', 'gd', vim.lsp.buf.definition, 'Go to definition')
map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
map('n', '<leader>ca', vim.lsp.buf.code_action, 'Code action')

-- Инсерт-комплишн (работает с nvim-cmp, а иначе пробует lsp.buf.completion)
map('i', '<C-Space>', function()
  local ok, cmp = pcall(require, 'cmp')
  if ok then
    cmp.complete()
  elseif vim.lsp.buf.completion then
    vim.lsp.buf.completion()
  end
end, 'Trigger completion')

-- ===== Telescope =====
local tb = require 'telescope.builtin'
map('n', '<leader><leader>', tb.find_files, 'Find files')
map('n', '<leader>fg', tb.live_grep, 'Live grep')
map('n', '<leader>fb', tb.buffers, 'Buffers')
map('n', '<leader>fh', tb.help_tags, 'Help tags')
map('n', '<leader>fd', tb.lsp_definitions, 'LSP definitions')

-- Доп. LSP навигация в едином стиле
map('n', 'grr', tb.lsp_references, '[G]oto [R]eferences')
map('n', 'gri', tb.lsp_implementations, '[G]oto [I]mplementation')
map('n', 'grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
map('n', 'gO', tb.lsp_document_symbols, 'Open Document Symbols')
map('n', 'gW', tb.lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
map('n', 'grt', tb.lsp_type_definitions, '[G]oto [T]ype Definition')
