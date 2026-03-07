local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local autoSavePath = vim.fn.stdpath("data") .. "/auto-save/auto-save.nvim"
if not vim.loop.fs_stat(autoSavePath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/pocco81/auto-save.nvim.git",
		"--branch=stable", -- latest stable release
		autoSavePath,
	})
end
vim.opt.rtp:prepend(autoSavePath)

require("lazy").setup({ { import = "josean.plugins" }, { import = "josean.plugins.lsp" } }, {
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		notify = false,
	},
})
