return {
  'stevearc/conform.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'ruff_format' },
      javascript = { 'prettierd', 'prettier', stop_after_first = true },
      javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      typescript = { 'prettierd', 'prettier', stop_after_first = true },
      typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      json = { 'prettierd', 'prettier', stop_after_first = true },
      jsonc = { 'prettierd', 'prettier', stop_after_first = true },
      yaml = { 'prettierd', 'prettier', stop_after_first = true },
      markdown = { 'prettierd', 'prettier', stop_after_first = true },
      html = { 'prettierd', 'prettier', stop_after_first = true },
      css = { 'prettierd', 'prettier', stop_after_first = true },
      scss = { 'prettierd', 'prettier', stop_after_first = true },
      less = { 'prettierd', 'prettier', stop_after_first = true },
    },
    format_on_save = function(bufnr)
      local ft = vim.bo[bufnr].filetype

      local disable_autoformat = {
        c = true,
        cpp = true,
      }

      local prettier_ft = {
        javascript = true,
        javascriptreact = true,
        typescript = true,
        typescriptreact = true,
        json = true,
        jsonc = true,
        yaml = true,
        markdown = true,
        html = true,
        css = true,
        scss = true,
        less = true,
      }

      if disable_autoformat[ft] then
        return nil
      end

      return {
        timeout_ms = 1000,
        lsp_fallback = not prettier_ft[ft],
      }
    end,
  },
  config = function(_, opts)
    require('conform').setup(opts)
  end,
}
