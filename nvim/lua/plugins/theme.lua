
return {
  'Mofiqul/vscode.nvim',
  priority = 1000,
  config = function()
    require('vscode').setup {
      style = 'dark',
      italic_comments = false,
    }
    vim.cmd.colorscheme 'vscode'

    -- Align Python keyword coloring closer to VSCode (with/as/in -> Keyword).
    local link = function(from, to)
      vim.api.nvim_set_hl(0, from, { link = to })
    end
    link('@keyword.python', 'Keyword')
    link('@keyword.operator.python', 'Keyword')
    link('@keyword.import.python', 'Keyword')
    link('@lsp.type.keyword.python', 'Keyword')

    -- Make error diagnostics stand out consistently across themes.
    vim.api.nvim_set_hl(0, 'DiagnosticUnderlineError', { undercurl = true, sp = '#f44747' })
    vim.api.nvim_set_hl(0, 'DiagnosticUnderlineWarn', { undercurl = true, sp = '#7fbbe3' })
    vim.api.nvim_set_hl(0, 'DiagnosticUnderlineInfo', { undercurl = true, sp = '#7fbbe3' })
    vim.api.nvim_set_hl(0, 'DiagnosticUnderlineHint', { undercurl = true, sp = '#7fbbe3' })
    vim.api.nvim_set_hl(0, 'DiagnosticUnnecessary', { undercurl = true, sp = '#7fbbe3' })
  end,
}
