return {
  "nmac427/guess-indent.nvim",
  event = { "BufReadPre" },
  config = function()
    local guess_indent = require("guess-indent")

    guess_indent.setup()
  end,
}
