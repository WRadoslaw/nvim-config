return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	config = function()
		-- import nvim-treesitter plugin
		local treesitter = require("nvim-treesitter.configs")

		local opt = vim.opt

		opt.foldmethod = "expr"
		opt.foldlevelstart = 99
		opt.foldexpr = "nvim_treesitter#foldexpr()"
		-- Remap 'zo' to toggle a fold instead of just opening it
		vim.keymap.set("n", "zo", "za", { desc = "Toggle fold (instead of just open)" })
		-- configure treesitter
		treesitter.setup({ -- enable syntax highlighting
			highlight = {
				enable = true,
			},
			-- ensure these language parsers are installed
			ensure_installed = {
				"json",
				"javascript",
				"typescript",
				"tsx",
				"yaml",
				"html",
				"css",
				"styled",
				"prisma",
				"markdown",
				"markdown_inline",
				"svelte",
				"graphql",
				"bash",
				"go",
				"lua",
				"vim",
				"rust",
				"dockerfile",
				"gitignore",
				"query",
				"vimdoc",
				"c",
				"python",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		})
	end,
}
