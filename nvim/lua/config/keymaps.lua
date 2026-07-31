local map = vim.keymap.set

vim.api.nvim_create_user_command("Keybindings", function()
  vim.cmd.edit(vim.fn.fnameescape(vim.fn.stdpath("config") .. "/KEYBINDINGS.md"))
end, { desc = "Abrir la guía de atajos" })

map("n", "<C-s>", "<cmd>w<cr>", { desc = "Guardar" })
map("i", "<C-s>", "<Esc><cmd>w<cr>", { desc = "Guardar" })
map("n", "<leader>?", "<cmd>Keybindings<cr>", { desc = "Abrir guía de atajos" })
map("i", "jj", "<Esc>", { desc = "Modo normal" })
