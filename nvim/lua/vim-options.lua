vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set clipboard=unnamedplus")
vim.g.mapleader = " "
-- Navigate vim panes better
vim.keymap.set('n', '<c-k>', ':wincmd k<CR>')
vim.keymap.set('n', '<c-j>', ':wincmd j<CR>')
vim.keymap.set('n', '<c-h>', ':wincmd h<CR>')
vim.keymap.set('n', '<c-l>', ':wincmd l<CR>')
-- :quit file
vim.keymap.set('i', '<Leader>q', ':q<CR>')
vim.keymap.set('n', '<Leader>q', ':q<CR>')
-- save file
vim.keymap.set('i', '<Leader>w', ':w<CR>')
vim.keymap.set('n', '<Leader>w', ':w<CR>')
-- change mode
vim.keymap.set('i', 'jj', '<Esc>')

vim.keymap.set('n', '<Leader>h', ':nohlsearch<CR>')
vim.wo.number = true

--  Split display
vim.keymap.set("n", "ss", ":split<Return>")
vim.keymap.set("n", "sv", ":vsplit<Return>")

