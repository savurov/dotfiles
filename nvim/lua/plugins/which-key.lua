return { -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  event = 'VimEnter', -- Sets the loading event to 'VimEnter'
  opts = {
    -- delay between pressing a key and opening which-key (milliseconds)
    -- this setting is independent of vim.o.timeoutlen
    delay = 0,
    preset = 'helix',
    spec = {
      { '<leader>l', group = 'lsp' },
      { '<leader>s', group = 'search' },
      { '<leader>d', group = 'debug' },
      { '<leader>p', group = 'print' },
    },
  },
}
