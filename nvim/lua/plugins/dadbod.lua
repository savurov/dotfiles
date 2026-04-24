return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'plsql' }, lazy = true },
  },
  ft = { 'sql', 'plsql' },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  init = function()
    local local_postgres_url = 'postgresql://local:local@localhost:5432/local'

    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_save_location = vim.fn.stdpath 'data' .. '/db_ui'
    vim.g.dbs = {
      { name = 'local', url = local_postgres_url },
    }
    vim.g.db = local_postgres_url

    local dadbod_sql_group = vim.api.nvim_create_augroup('dadbod_sql_completion', { clear = true })

    vim.api.nvim_create_autocmd('FileType', {
      group = dadbod_sql_group,
      pattern = { 'sql', 'plsql' },
      callback = function(event)
        vim.bo[event.buf].omnifunc = 'vim_dadbod_completion#omni'

        if vim.b[event.buf].db == nil or vim.b[event.buf].db == '' then
          vim.b[event.buf].db = local_postgres_url
        end
      end,
    })
  end,
}
