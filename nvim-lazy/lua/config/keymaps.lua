-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "n", "v" }, "<C-y>", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set({ "n", "v" }, "<C-p>", '"+P', { desc = "Paste from system clipboard" })
vim.keymap.set("v", "<C-c>", '"+y', { noremap = true, silent = true, desc = "Copy to clipboard" })
