return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      require("lspconfig").dartls.setup({})
    end,
  },
}
