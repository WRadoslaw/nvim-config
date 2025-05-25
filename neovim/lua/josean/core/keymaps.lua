vim.g.mapleader = " "

local keymap = vim.keymap

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
-- keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
-- keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
-- keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab
keymap.set("x", "p", "pgvy", { noremap = true, silent = true })

keymap.set("i", "<C-h>", "<C-w>", { noremap = true, silent = true })
keymap.set("i", "<C-v>", '<C-r>"', { noremap = true, silent = true })

keymap.set("n", "<S-h>", "20k", { noremap = true, silent = true })
keymap.set("n", "<S-j>", "20j", { noremap = true, silent = true })

keymap.set("n", "<leader>co", function()
    local absolute_path = vim.fn.expand("%:p")
    vim.fn.setreg("+", absolute_path)
    vim.notify("Copied absolute path: " .. absolute_path)
end, { desc = "Copy absolute file path to clipboard" })

keymap.set("n", "<leader>cp", function()
    local relative_path = vim.fn.expand("%:.")
    vim.fn.setreg("+", relative_path)
    vim.notify("Copied relative path: " .. relative_path)
end, { desc = "Copy relative file path to clipboard" })

