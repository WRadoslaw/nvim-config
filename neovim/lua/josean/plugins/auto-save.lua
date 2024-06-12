return {
	"0x00-ketsu/autosave.nvim",
	event = { "FocusLost", "BufLeave", "WinLeave", "BufWinEnter", "TabLeave" },
	config = function()
		require("autosave").setup({
			enable = true,
			prompt_style = "stdout",
			prompt_message = function()
				return "Autosave: saved at " .. vim.fn.strftime("%H:%M:%S")
			end,
			events = { "FocusLost", "BufLeave", "WinLeave", "BufWinEnter", "TabLeave" },
			callback = function()
				if vim.bo.ft == "harpoon" then
					return
				end
				vim.cmd("silent! wall")
			end,
			conditions = {
				exists = true,

				modifiable = true,
				filename_is_not = {},
				filetype_is_not = {},
			},
			write_all_buffers = false,
			debounce_delay = 5000,
		})
	end,
}
