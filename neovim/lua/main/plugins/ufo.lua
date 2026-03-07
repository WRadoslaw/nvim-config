-- Assuming you use a plugin manager like `lazy.nvim`
return {
	{
		"kevinhwang91/nvim-ufo",
		dependencies = {
			"kevinhwang91/promise-async",
		},
		config = function()
			vim.o.foldcolumn = "1" -- '0' is not bad
			vim.o.foldlevel = 99 -- set to 99 to be able to see all folds
			vim.o.foldmethod = "manual" -- UFO will manage this for you
			vim.keymap.set("n", "zR", require("ufo").openAllFolds)
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
			vim.keymap.set("n", "zK", function()
				local winid = require("ufo").peekFoldedLines()
				if winid then
					return "<esc>"
				else
					return "zK"
				end
			end, { silent = true, expr = true })

			require("ufo").setup({
				provider_selector = function(bufnr, filetype, buftype)
					-- You can specify different providers for different file types
					-- For example, use LSP for Python and Tree-sitter for Lua
					if vim.lsp.buf_get_clients(bufnr) then
						return { "lsp", "indent" }
					else
						return { "treesitter", "indent" }
					end
				end,
			})
		end,
	},
}
