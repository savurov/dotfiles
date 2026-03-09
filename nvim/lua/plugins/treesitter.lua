return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  lazy = false,
  opts = {
    ensure_installed = {
      'bash',
      'c',
      'diff',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'python',
      'query',
      'vim',
      'vimdoc',
    },
    auto_install = true,

    highlight = {
      enable = true,
    },

    indent = {
      enable = true,
    },
  },
}
