return {
	{
		"tpope/vim-fugitive",
	},
	{
		"dinhhuy258/git.nvim",
		event = "BufReadPre",
		cmd = { "Git", "GitBlame", "GitDiff", "GitDiffClose", "GitRevert", "GitRevertFile" },
		opts = {
       signs = {
    add = { text = "│" },
    change = { text = "│" },
    delete = { text = "󰍵" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "│" },
  },
			keymaps = {
				-- Open blame window
				blame = "<Leader>gb",
				-- Open file/folder in git repository
				browse = "<Leader>go",
				-- Compare the current file against the Git index.
				diff = "<Leader>gd",
				diff_close = "<Leader>gD",
				revert = "<Leader>gr",
				revert_file = "<Leader>gR",
			},
		},
	},
}
