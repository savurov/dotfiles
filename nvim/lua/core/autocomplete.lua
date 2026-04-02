local M = {}

local enabled = true

function M.is_enabled()
  return enabled
end

function M.toggle()
  enabled = not enabled

  local ok, blink = pcall(require, 'blink.cmp')
  if ok and blink.is_visible() then
    blink.hide()
  end

  vim.notify('Autocomplete: ' .. (enabled and 'on' or 'off'), vim.log.levels.INFO)
  return enabled
end

return M
