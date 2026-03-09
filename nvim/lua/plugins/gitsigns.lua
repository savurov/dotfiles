return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    signcolumn = true,
    signs_staged_enable = true,
    signs = {
      add = { text = '▎' },
      change = { text = '▎' },
      delete = { text = '▁' },
      topdelete = { text = '▔' },
      changedelete = { text = '▎' },
      untracked = { text = '▎' },
    },
    signs_staged = {
      add = { text = '▎' },
      change = { text = '▎' },
      delete = { text = '▁' },
      topdelete = { text = '▔' },
      changedelete = { text = '▎' },
      untracked = { text = '▎' },
    },
  },
  config = function(_, opts)
    require('gitsigns').setup(opts)

    local set_hl = vim.api.nvim_set_hl
    set_hl(0, 'GitSignsAdd', { fg = '#81b88b' })
    set_hl(0, 'GitSignsChange', { fg = '#e2c08d' })
    set_hl(0, 'GitSignsDelete', { fg = '#e06c75' })
    set_hl(0, 'GitSignsStagedAdd', { fg = '#81b88b' })
    set_hl(0, 'GitSignsStagedChange', { fg = '#81b88b' })
    set_hl(0, 'GitSignsStagedDelete', { fg = '#81b88b' })
  end,
}
