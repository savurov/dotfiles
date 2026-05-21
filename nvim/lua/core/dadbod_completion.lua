local M = {}

local ok_source, dadbod_source = pcall(require, 'vim_dadbod_completion.blink')

local trigger_characters = { '"', '`', '[', ']', '.' }
local sql_filetypes = { sql = true, mysql = true, plsql = true }

local function current_buf()
  return vim.api.nvim_get_current_buf()
end

local function get_input(ctx)
  local cursor_col = ctx.cursor[2]
  local line = ctx.line
  local word_start = cursor_col + 1

  while word_start > 1 do
    local char = line:sub(word_start - 1, word_start - 1)
    if vim.tbl_contains(trigger_characters, char) or char:match('%s') then
      break
    end
    word_start = word_start - 1
  end

  local input = line:sub(word_start, cursor_col)
  if input ~= '' and input:match('[^0-9A-Za-z_]+') then
    input = ''
  end

  local previous_char = line:sub(cursor_col, cursor_col)
  local is_trigger = vim.tbl_contains(trigger_characters, previous_char)

  return input, is_trigger
end

local function active_db_exists(bufnr)
  local env_db = vim.env.DATABASE_URL
  if env_db and env_db ~= '' then
    return true
  end

  local dbui_db_key_name = vim.b[bufnr].dbui_db_key_name
  if dbui_db_key_name and dbui_db_key_name ~= '' then
    return true
  end

  for _, scope in ipairs { vim.b[bufnr], vim.w, vim.t, vim.g } do
    if type(scope) == 'table' and scope.db and scope.db ~= '' then
      return true
    end
  end

  return false
end

local function notify_once(bufnr, message)
  if vim.b[bufnr].dadbod_completion_notice == message then
    return
  end

  vim.b[bufnr].dadbod_completion_notice = message
  vim.schedule(function()
    vim.notify(message, vim.log.levels.INFO, { title = 'dadbod' })
  end)
end

local function keyword_items(input)
  local ok, keywords = pcall(vim.api.nvim_call_function, 'vim_dadbod_completion#reserved_keywords#get', {})
  if not ok or type(keywords) ~= 'table' then
    return {}
  end

  local items = {}
  local prefix = input:lower()

  for _, keyword in ipairs(keywords) do
    if prefix == '' or keyword:lower():find('^' .. vim.pesc(prefix)) then
      items[#items + 1] = {
        label = keyword,
        insertText = keyword,
        kind = vim.lsp.protocol.CompletionItemKind.Keyword,
        documentation = 'SQL keyword',
      }
    end
  end

  return items
end

function M.new()
  local source = ok_source and dadbod_source.new() or nil
  return setmetatable({ source = source }, { __index = M })
end

function M:get_trigger_characters()
  return trigger_characters
end

function M:enabled()
  return sql_filetypes[vim.bo.filetype] == true
end

function M:get_completions(ctx, callback)
  local bufnr = current_buf()
  local input, is_trigger = get_input(ctx)

  if not active_db_exists(bufnr) then
    if input == '' and not is_trigger then
      callback({
        context = ctx,
        is_incomplete_forward = false,
        is_incomplete_backward = false,
        items = {},
      })
      return function() end
    end

    notify_once(bufnr, "[dadbod]: database not found, using SQL keywords only")
    callback({
      context = ctx,
      is_incomplete_forward = false,
      is_incomplete_backward = false,
      items = keyword_items(input),
    })
    return function() end
  end

  if not self.source then
    callback({
      context = ctx,
      is_incomplete_forward = false,
      is_incomplete_backward = false,
      items = keyword_items(input),
    })
    return function() end
  end

  local ok, cancel = pcall(self.source.get_completions, self.source, ctx, callback)
  if ok then
    return cancel
  end

  notify_once(bufnr, "[dadbod]: failed to connect, using SQL keywords only")
  callback({
    context = ctx,
    is_incomplete_forward = false,
    is_incomplete_backward = false,
    items = keyword_items(input),
  })
  return function() end
end

return M
