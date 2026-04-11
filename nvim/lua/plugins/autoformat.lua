return {
  'stevearc/conform.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'ruff_format' },
      javascript = { 'prettierd', 'prettier' },
      javascriptreact = { 'prettierd', 'prettier' },
      typescript = { 'prettierd', 'prettier' },
      typescriptreact = { 'prettierd', 'prettier' },
      json = { 'prettierd', 'prettier' },
      jsonc = { 'prettierd', 'prettier' },
      yaml = { 'prettierd', 'prettier' },
      markdown = { 'prettierd', 'prettier' },
      html = { 'prettierd', 'prettier' },
      css = { 'prettierd', 'prettier' },
      scss = { 'prettierd', 'prettier' },
      less = { 'prettierd', 'prettier' },
      gopls = { 'goimports', 'gofumpt' },
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
