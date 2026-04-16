return {
  {
    'okuuva/auto-save.nvim',
    version = '^1.0.0',
    cmd = 'ASToggle',
    event = { 'InsertLeave', 'TextChanged' },
    opts = {
      enabled = true,
      condition = function(buf)
        local name = vim.api.nvim_buf_get_name(buf)

        if name == '' then
          return false
        end

        if name:match '^/tmp/nvim%.hijack/' then
          return false
        end

        return true
      end,
    },
  },
}
