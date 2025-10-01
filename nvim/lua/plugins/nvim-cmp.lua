return {
  "saghen/blink.cmp",
  opts = {
    -- only show when you ask for it
    completion = {
      menu = { auto_show = false }, -- <-- key line
      ghost_text = { enabled = false }, -- optional: no inline “gray” text
      list = { selection = { preselect = false, auto_insert = false } }, -- avoid auto-pick
    },
    keymap = {
      preset = "enter", -- keep sane <CR> behavior
      ["<C-Space>"] = { "show" }, -- manual popup
    },
    -- (optional) also disable cmdline ghost text/popup if it annoys you:
    cmdline = { completion = { menu = { auto_show = false }, ghost_text = { enabled = false } } },
  },
}
