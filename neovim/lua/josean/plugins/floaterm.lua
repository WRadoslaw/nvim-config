return {
	"voldikss/vim-floaterm",
	event = "VeryLazy",
	config = function()
		-- Set keymaps for Floaterm
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<leader>tt", ":FloatermToggle<CR>", { desc = "Toggle Floaterm" })

		-- Floaterm settings
		vim.g.floaterm_position = "center"
		vim.g.floaterm_width = 0.8
		vim.g.floaterm_height = 0.8

		-- Optional: Configure Floaterm appearance and behavior
		vim.g.floaterm_borderchars = "─│─│╭╮╯╰"
		vim.g.floaterm_autoinsert = 1
		vim.g.floaterm_title = ""
		vim.g.floaterm_autoclose = 1

		keymap.set(
			"t",
			"<C-o>",
			"<C-\\><C-n>:q<CR>",
			{ noremap = true, silent = true, desc = "Exit terminal without killing it" }
		)
		keymap.set(
			"t",
			"jk",
			"<C-\\><C-n>",
			{ noremap = true, silent = true, desc = "Exit terminal without killing it" }
		)
		keymap.set(
			"t",
			"<C-h>",
			"<C-\\><C-n>:FloatermPrev<CR>",
			{ noremap = true, silent = true, desc = "In terminal go prev with Ctrl+H" }
		)
		keymap.set(
			"t",
			"<C-l>",
			"<C-\\><C-n>:FloatermNext<CR>",
			{ noremap = true, silent = true, desc = "In terminal go prev with Ctrl+L" }
		)
		for i = 1, 9 do
			keymap.set(
				"n",
				"<leader>t" .. i,
				":FloatermToggle --name  " .. i .. " <CR>",
				{ noremap = true, silent = true, desc = "Open Floaterm " .. i }
			)
		end
	end,
}
