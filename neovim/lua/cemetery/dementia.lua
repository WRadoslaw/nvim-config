return {
	"WRadoslaw/dementia",
	branch = "main",
	dependencies = {
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		require("dementia")
		local keymap = vim.keymap

		keymap.set(
			"n",
			"<leader>ms",
			':lua require("dementia").show_modified_buffers()<CR>',
			{ noremap = true, silent = true }
		)
	end,
}
