vim.o.exrc = true
vim.o.secure = true

vim.lsp.enable("pyright")
vim.lsp.enable("ts_ls")
vim.lsp.enable("html")
vim.lsp.enable("cssls")
vim.lsp.enable("lua_ls")

vim.diagnostic.config({ virtual_text = true })

require("josean.core")
require("josean.lazy")
