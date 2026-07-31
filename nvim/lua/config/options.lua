vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

-- LazyGit on Windows invokes cmd.exe; include the system command directory
-- when Neovim inherits an incomplete PATH from a terminal host.
local system32 = (vim.env.SystemRoot or "C:\\Windows") .. "\\System32"
if not vim.env.PATH:lower():find(system32:lower(), 1, true) then
  vim.env.PATH = system32 .. ";" .. vim.env.PATH
end
