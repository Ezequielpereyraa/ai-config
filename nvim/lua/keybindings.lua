local map = vim.keymap.set
local opts = { noremap = true, silent = true }

vim.api.nvim_create_user_command("Keybindings", function()
  vim.cmd.edit(vim.fn.fnameescape(vim.fn.stdpath("config") .. "/KEYBINDINGS.md"))
end, { desc = "Abrir la guía de atajos" })

-- File operations (Ctrl+S → save)
map("n", "<C-s>", ":w<CR>", vim.tbl_extend("force", opts, { desc = "Guardar" }))
map("i", "<C-s>", "<Esc>:w<CR>", vim.tbl_extend("force", opts, { desc = "Guardar" }))
map("n", "<Leader>wa", ":wa<CR>", vim.tbl_extend("force", opts, { desc = "Guardar todo" }))

-- Move lines (Shift+Alt+J/K)
map("n", "<A-j>", ":m .+1<CR>==", opts)
map("n", "<A-k>", ":m .-2<CR>==", opts)
map("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
map("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- Insert lines before/after (Ctrl+Enter / Alt+Enter)
map("n", "<C-CR>", "O", opts)
map("i", "<C-CR>", "<Esc>O", opts)
map("n", "<A-CR>", "o", opts)
map("i", "<A-CR>", "<Esc>o", opts)

-- Comment aliases for familiarity (Alt+\ block, Alt+/ line)
-- Comment.nvim already handles gc/gb; these are extras
map("n", "<A-/>", "gcc", opts)
map("x", "<A-/>", "gc", opts)
map("n", "<A-\\>", "gbc", opts)
map("x", "<A-\\>", "gb", opts)

-- Files and search. Leader mappings work consistently in every terminal.
map("n", "<C-p>", ":Telescope find_files<CR>", vim.tbl_extend("force", opts, { desc = "Buscar archivos" }))
map("n", "<C-S-f>", ":Telescope live_grep<CR>", vim.tbl_extend("force", opts, { desc = "Buscar en proyecto" }))
map("n", "<Leader>ff", ":Telescope find_files<CR>", vim.tbl_extend("force", opts, { desc = "Buscar archivos" }))
map("n", "<Leader>fb", ":Telescope buffers<CR>", vim.tbl_extend("force", opts, { desc = "Buscar buffers" }))
map("n", "<Leader>fg", ":Telescope live_grep<CR>", vim.tbl_extend("force", opts, { desc = "Buscar en proyecto" }))
map("n", "<Leader>fw", ":Telescope grep_string<CR>", vim.tbl_extend("force", opts, { desc = "Buscar palabra bajo cursor" }))
map("n", "<Leader>fk", ":Telescope keymaps<CR>", vim.tbl_extend("force", opts, { desc = "Buscar atajos" }))
map("n", "<Leader>?", ":Keybindings<CR>", vim.tbl_extend("force", opts, { desc = "Abrir guía de atajos" }))

-- Buffer navigation. Ctrl+Tab is convenient in GUI clients; ]b/[b works everywhere.
map("n", "<C-Tab>", ":bnext<CR>", vim.tbl_extend("force", opts, { desc = "Buffer siguiente" }))
map("n", "<C-S-Tab>", ":bprevious<CR>", vim.tbl_extend("force", opts, { desc = "Buffer anterior" }))
map("n", "]b", ":bnext<CR>", vim.tbl_extend("force", opts, { desc = "Buffer siguiente" }))
map("n", "[b", ":bprevious<CR>", vim.tbl_extend("force", opts, { desc = "Buffer anterior" }))

-- File explorer. Ctrl+E matches VS Code; Leader+e is the terminal-safe fallback.
map("n", "<C-e>", ":Neotree toggle<CR>", vim.tbl_extend("force", opts, { desc = "Alternar explorador" }))
map("n", "<C-b>", ":Neotree toggle<CR>", vim.tbl_extend("force", opts, { desc = "Alternar explorador" }))
map("n", "<Leader>e", ":Neotree toggle<CR>", vim.tbl_extend("force", opts, { desc = "Alternar explorador" }))

-- Git status is available through the existing git.nvim integration.
map("n", "<Leader>gs", ":Git status<CR>", vim.tbl_extend("force", opts, { desc = "Git status" }))

-- Git branch checkout (Shift+Alt+B → Telescope)
map("n", "<Leader>gb", ":Telescope git_branches<CR>", opts)

-- Fold / Unfold (Ctrl+[ / Ctrl+] in VS Code)
-- Ctrl+[ is <Esc> in vim, can't remap. Using vim natives:
--   zc = fold, zo = unfold, za = toggle, zM = fold all, zR = open all
