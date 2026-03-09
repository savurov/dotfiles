return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = function()
    -- 🧩 Active LSP client(s)
    local function lsp_name()
      local clients = vim.lsp.get_clients { bufnr = 0 }
      if not clients or #clients == 0 then
        return ''
      end
      local names = {}
      for _, c in ipairs(clients) do
        table.insert(names, c.name)
      end
      return ' ' .. table.concat(names, ',')
    end

    -- 🐍 Python virtual env
    local function venv_name()
      local venv = os.getenv 'VIRTUAL_ENV'
      if venv then
        return ' ' .. vim.fn.fnamemodify(venv, ':t')
      end
      return ''
    end

    -- 💬 Noice command/status integration (modern API)
    local function noice_status()
      local ok, noice = pcall(require, 'noice')
      if not ok then
        return ''
      end
      local api = noice.api.status
      if api and api.command and api.command.has() then
        return api.command.get()
      elseif api and api.mode and api.mode.has() then
        return api.mode.get()
      elseif api and api.search and api.search.has() then
        return api.search.get()
      end
      return ''
    end

    return {
      options = {
        theme = 'auto',
        globalstatus = true,
        section_separators = '',
        component_separators = '',
        disabled_filetypes = { 'lazy', 'neo-tree', 'NvimTree' },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = {},
        lualine_c = {
          { 'filename', path = 1 },
        },
        lualine_x = {
          { noice_status },
          { 'diagnostics' },
          { lsp_name },
          { venv_name },
          { 'filetype', icon_only = true },
        },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
    }
  end,
}
