vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

vim.g.clipboard = 'osc52'

vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.wrap = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
-- vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.listchars = { tab = '  ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.wildmenu = true
vim.o.termguicolors = true

vim.o.undofile = true

-- Persistent recovery: keep undo/swap/backup files in writable state dir.
local state = vim.fn.stdpath 'state'
local undodir = state .. '/undo//'
local swapdir = state .. '/swap//'
local backupdir = state .. '/backup//'

for _, dir in ipairs { undodir, swapdir, backupdir } do
  vim.fn.mkdir(dir, 'p')
end

vim.o.undodir = undodir
vim.o.directory = swapdir
vim.o.backupdir = backupdir

vim.o.swapfile = true
vim.o.backup = true
vim.o.writebackup = true
vim.o.undolevels = 10000

vim.o.autoread = true
vim.o.updatetime = 300
