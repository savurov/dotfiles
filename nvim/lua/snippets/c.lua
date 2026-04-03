local M = {}

local function is_c_buffer()
  return vim.bo.filetype == 'c'
end

local function warn_not_c(lhs)
  vim.notify(lhs .. ' works only in C buffers', vim.log.levels.WARN)
end

local function ensure_stdio_include(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for _, line in ipairs(lines) do
    if line:match '^%s*#%s*include%s*<stdio%.h>' then
      return
    end
  end

  local insert_at = 0
  local first_nonblank = 1

  while first_nonblank <= #lines and lines[first_nonblank]:match '^%s*$' do
    first_nonblank = first_nonblank + 1
  end

  local first_line = lines[first_nonblank]
  if first_line == nil then
    vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, { '#include <stdio.h>' })
    return
  end

  if first_line:match '^%s*//' then
    local last_comment = first_nonblank
    while last_comment <= #lines and lines[last_comment]:match '^%s*//' do
      last_comment = last_comment + 1
    end
    insert_at = last_comment - 1
  elseif first_line:match '^%s*/%*' then
    local last_comment = first_nonblank
    while last_comment <= #lines do
      if lines[last_comment]:match '%*/%s*$' then
        break
      end
      last_comment = last_comment + 1
    end
    insert_at = last_comment
  end

  vim.api.nvim_buf_set_lines(bufnr, insert_at, insert_at, false, { '#include <stdio.h>' })
end

local function current_row()
  return vim.api.nvim_win_get_cursor(0)[1]
end

local function current_indent(bufnr, row)
  local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ''

  if line:match '^%s*$' then
    for prev = row - 1, 1, -1 do
      local prev_line = vim.api.nvim_buf_get_lines(bufnr, prev - 1, prev, false)[1] or ''
      if not prev_line:match '^%s*$' then
        return prev_line:match '^%s*' or ''
      end
    end
  end

  return line:match '^%s*' or ''
end

local function insert_line_below(bufnr, row, text)
  vim.api.nvim_buf_set_lines(bufnr, row, row, false, { text })
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
end

local function ensure_c_context(lhs)
  if not is_c_buffer() then
    warn_not_c(lhs)
    return nil
  end

  local bufnr = vim.api.nvim_get_current_buf()
  ensure_stdio_include(bufnr)

  local row = current_row()
  return {
    bufnr = bufnr,
    row = row,
    indent = current_indent(bufnr, row),
  }
end

function M.printf(format_spec)
  local ctx = ensure_c_context '<leader>p*'
  if ctx == nil then
    return
  end

  local line = string.format('%sprintf("%%%s\\n", );', ctx.indent, format_spec)
  insert_line_below(ctx.bufnr, ctx.row, line)
  vim.api.nvim_win_set_cursor(0, { ctx.row + 1, #line - 1 })
  vim.cmd.startinsert()
end

function M.array_loop()
  local ctx = ensure_c_context '<leader>pa'
  if ctx == nil then
    return
  end

  local ok, ls = pcall(require, 'luasnip')
  if not ok then
    vim.notify('LuaSnip is not available', vim.log.levels.ERROR)
    return
  end

  local rep_ok, extras = pcall(require, 'luasnip.extras')
  if not rep_ok then
    vim.notify('LuaSnip extras are not available', vim.log.levels.ERROR)
    return
  end

  insert_line_below(ctx.bufnr, ctx.row, '')
  vim.api.nvim_win_set_cursor(0, { ctx.row + 1, 0 })

  ls.snip_expand(ls.s('', {
    ls.t { ctx.indent .. 'for (int i = 0; i < sizeof(' },
    ls.i(1, 'arr'),
    ls.t { ') / sizeof(' },
    extras.rep(1),
    ls.t { '[0]); i++) {', ctx.indent .. '\tprintf(' },
    ls.i(2, '"%d\\n"'),
    ls.t { ', ' },
    extras.rep(1),
    ls.t { '[i]);', ctx.indent .. '}' },
    ls.i(0),
  }))
end

return M
