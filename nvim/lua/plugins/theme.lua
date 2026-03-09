
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
  end,
}
