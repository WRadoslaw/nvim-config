return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup({})
		harpoon.logger:show()
		require("telescope").load_extension("harpoon")
		local keymap = vim.keymap

		keymap.set("n", "<leader>ha", function()
			harpoon:list():add()
		end, { desc = "Harpoon add file" })

		keymap.set("n", "<leader>hn", function()
			-- toggle_telescope((harpoon:list()))
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Harpoon add file" })
	end,
}
