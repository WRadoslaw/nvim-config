return {
  "ibhagwan/fzf-lua",
  -- optional for icon support
  -- cmd = "FzfLua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- calling `setup` is optional for customization
    require("fzf-lua").setup({})


    local keymap = vim.keymap

    keymap.set("n", "<leader>ff", "<cmd>lua require('fzf-lua').files()<cr>")
    keymap.set("n", "<leader>fg", "<cmd>lua require('fzf-lua').git_files()<cr>")
    keymap.set("n", "<leader>fr", "<cmd>lua require('fzf-lua').oldfiles()<cr>")
    keymap.set("n", "<leader>fs", "<cmd>lua require('fzf-lua').live_grep()<cr>")
    keymap.set("n", "<leader>fz", "<cmd>lua require('fzf-lua').resume()<cr>")
    -- git
    keymap.set("n", "<leader>gc", "<cmd>lua require('fzf-lua').git_commits()<cr>")
    keymap.set("n", "<leader>gs", "<cmd>lua require('fzf-lua').git_status()<cr>")
  end
}
