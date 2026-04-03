return {
  {
    'L3MON4D3/LuaSnip',
    version = 'v2.*',
    build = 'make install_jsregexp',
    opts = {
      history = true,
      updateevents = 'TextChanged,TextChangedI,InsertLeave',
    },
    config = function(_, opts)
      local ls = require 'luasnip'
      ls.setup(opts)

      require('luasnip.loaders.from_lua').lazy_load {
        paths = { vim.fn.stdpath 'config' .. '/snippets' },
      }
    end,
  },
}
