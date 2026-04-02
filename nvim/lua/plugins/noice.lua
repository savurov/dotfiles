return {
  'folke/noice.nvim',
  opts = {
    messages = {
      enabled = false,
    },
    lsp = {
      signature = {
        enabled = false,
        opts = {
          size = {
            max_width = 60,
            max_height = 15,
          },
        },
      },
    },
  },
}
