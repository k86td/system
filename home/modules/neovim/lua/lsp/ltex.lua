-- LTeX language server for grammar/spell checking
vim.lsp.config['ltex'] = {
  cmd = { 'ltex-ls' },
  filetypes = { "typst", "markdown" },
  settings = {
    ltex = {
      language = "en,fr",
    },
  },
}
vim.lsp.enable('ltex')
