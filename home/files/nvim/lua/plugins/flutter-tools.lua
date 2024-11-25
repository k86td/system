return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      require("lspconfig").dartls.setup({})
      vim.cmd([[autocmd BufWritePre * lua vim.lsp.buf.format()]])
    end,
  },
}
