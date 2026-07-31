return {
  {
    "folke/snacks.nvim",
    opts = { explorer = {}, lazygit = {} },
    keys = {
      { "<C-p>", function() Snacks.picker.files() end, desc = "Buscar archivos" },
      { "<C-b>", function() Snacks.explorer() end, desc = "Alternar explorador" },
      { "<leader>fg", function() Snacks.picker.grep() end, desc = "Buscar en proyecto" },
      { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "Buscar palabra bajo cursor" },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buscar buffers" },
      { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Buscar atajos" },
      { "<leader>gg", function() Snacks.lazygit({ cwd = LazyVim.root.git() }) end, desc = "LazyGit (raíz Git)" },
    },
  },
}
