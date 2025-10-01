return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    -- Just extend the existing configuration
    opts.event_handlers = opts.event_handlers or {}
    table.insert(opts.event_handlers, {
      event = "file_open_requested",
      handler = function()
        require("neo-tree.command").execute({ action = "close" })
      end,
    })
  end,
}
