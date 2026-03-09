return {
  'kawre/leetcode.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'nvim-telescope/telescope.nvim',
  },
  opts = {
    arg = 'leetcode.nvim',
    lang = 'python3',
    cn = {
      enabled = false,
      translator = true,
      translate_problems = true,
    },
    storage = {
      home = vim.fn.stdpath 'data' .. '/leetcode',
      cache = vim.fn.stdpath 'cache' .. '/leetcode',
    },
    logging = true,
    cache = {
      update_interval = 60 * 60 * 24 * 7,
    },
    editor = {
      reset_previous_code = true,
      fold_imports = true,
    },
    console = {
      open_on_runcode = true,
      dir = 'row',
      size = {
        width = '90%',
        height = '75%',
      },
      result = {
        size = '60%',
      },
      testcase = {
        virt_text = true,
        size = '40%',
      },
    },
    description = {
      position = 'left',
      width = '40%',
      show_stats = true,
    },
    picker = {
      provider = 'telescope',
    },
    plugins = {
      non_standalone = false,
    },
    image_support = false,
  },
}
