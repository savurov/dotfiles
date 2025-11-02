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

-- Neo-tree: надёжный toggle через API
map('n', '<leader>e', function()
  require('neo-tree.command').execute { toggle = true }
end, 'Toggle Neo-tree')

-- Копировать в системный буфер в визуальном режиме
map('v', '<C-c>', '"+y', 'Copy to system clipboard')

-- Quit
map('n', '<leader>q', '<cmd>qa<CR>', 'Quit')

-- ===== Telescope =====
local tb = require 'telescope.builtin'
map('n', '<leader><leader>', tb.find_files, 'Find files')
map('n', '<leader>sf', tb.find_files, 'Find [f]iles')
map('n', '<leader>sg', tb.live_grep, 'Live [g]rep')
map('n', '<leader>sb', tb.oldfiles, '[s]earch [b]ack')

map('n', '<leader>sh', tb.help_tags, '[S]earch [H]elp')
map('n', '<leader>sk', tb.keymaps, '[S]earch [K]eymaps')
map('n', '<leader>ss', tb.builtin, '[S]earch [S]elect Telescope')
map('n', '<leader>sw', tb.grep_string, '[S]earch current [W]ord')
map('n', '<leader>sd', tb.diagnostics, '[S]earch [D]iagnostics')
map('n', '<leader>sr', tb.resume, '[S]earch [R]esume last searcn')

map('n', '<leader>sn', function()
  tb.find_files { cwd = vim.fn.stdpath 'config' }
end, '[S]earch [N]eovim files')
map('n', '<leader>sc', function()
  tb.find_files { cwd = '~/.config' }
end, '[S]earch [C]onfig files')
-- ===== LSP =====
map('n', 'K', vim.lsp.buf.hover, 'Hover info')
map('n', 'gd', vim.lsp.buf.definition, 'Go to definition')
map('n', 'ge', vim.diagnostic.open_float, 'Show diagnostics popup')
map('n', 'gr', tb.lsp_references, '[G]oto [R]eferences')
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

map('n', '<leader>gg', '<cmd>LazyGit<cr>', 'LazyGit (float)')
local last_buf = nil

vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    local current = vim.api.nvim_get_current_buf()
    if current ~= last_buf then
      vim.b.previous_buf = last_buf
      last_buf = current
    end
  end,
})

vim.keymap.set('n', '<leader>b', function()
  local prev = vim.b.previous_buf
  if prev and vim.api.nvim_buf_is_valid(prev) then
    vim.api.nvim_set_current_buf(prev)
  else
    vim.notify('No previous buffer', vim.log.levels.WARN)
  end
end, { desc = 'Toggle previous buffer' })
