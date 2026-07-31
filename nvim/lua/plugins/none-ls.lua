return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
  },
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.diagnostics.erb_lint,
        null_ls.builtins.formatting.prettier.with({
          condition = function(utils)
            return utils.root_has_file({ ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json" }) -- only enable if root has .eslintrc.js or .eslintrc.cjs
          end,
        }),
        null_ls.builtins.diagnostics.rubocop,
        null_ls.builtins.formatting.rubocop,
      },
    })

    vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, { desc = "Formatear archivo" })
  end,
}

-- return {
--	"nvimtools/none-ls.nvim",
--config = function()
--local null_ls = require("null-ls")
-- 	null_ls.setup({
--	ensure_installed = {
--	"prettier", -- prettier formatter
--"stylua", -- lua formatter
--"black", -- python formatter
--"pylint", -- python linter
--	"eslint_d", -- js linter
--	},
--	sources = {
--	null_ls.builtins.formatting.stylua,
--	null_ls.builtins.formatting.prettier,
--null_ls.builtins.diagnostics.erb_lint,
--null_ls.builtins.diagnostics.eslint_d.with({
--condition = function(utils)
--return utils.root_has_file({ ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json" }) -- only enable if root has .eslintrc.js or .eslintrc.cjs
--end,
--}),
--	null_ls.builtins.diagnostics.rubocop,
--	null_ls.builtins.formatting.rubocop,
--	},
--	})

--vim.keymap.set("n", "<leader>ff", vim.lsp.buf.format, {})
--	end
--}
