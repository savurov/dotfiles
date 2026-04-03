local ls = require 'luasnip'
local events = require 'luasnip.util.events'
local rep = require('luasnip.extras').rep

local s = ls.s
local i = ls.i
local t = ls.t

local function ensure_stdio_include()
  local bufnr = vim.api.nvim_get_current_buf()
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

local function with_stdio()
  return {
    callbacks = {
      [-1] = {
        [events.pre_expand] = ensure_stdio_include,
      },
    },
  }
end

local function printf_snippet(trigger, format_spec, default_value, name)
  return s({
    trig = trigger,
    name = name,
    dscr = 'Insert printf("' .. format_spec .. '\\n", ...);',
  }, {
    t('printf("' .. format_spec .. '\\n", '),
    i(1, default_value),
    t ');',
    i(0),
  }, with_stdio())
end

return {
  printf_snippet('ps', '%s', 'str', 'printf string'),
  printf_snippet('pd', '%d', 'value', 'printf decimal'),
  printf_snippet('pz', '%zu', 'len', 'printf size_t'),
  printf_snippet('pp', '%p', 'ptr', 'printf pointer'),
  printf_snippet('pf', '%f', 'value', 'printf float'),
  s({
    trig = 'pa',
    name = 'array loop',
    dscr = 'Iterate array and print each element',
  }, {
    t { 'int count = (int) sizeof(' },
    i(1, 'arr'),
    t { ') / sizeof(' },
    rep(1),
    t { '[0]);', 'for (int i = 0; i < count; i++) {', '\tprintf("%d ", ' },
    rep(1),
    t { '[i]);', '}', 'printf("\\n");' },
    i(0),
  }, with_stdio()),
  s({
    trig = 'main',
    name = 'main function',
    dscr = 'Insert int main(void) skeleton',
  }, {
    t { 'int main(void) {', '\t' },
    i(1),
    t { '', '\treturn 0;', '}' },
    i(0),
  }),
}
