local capabilities = require('lsp.capabilities').capabilities

vim.lsp.config['clangd'] = {
  cmd = { 'clangd', '--background-index', '--clang-tidy', '--log=verbose' },
  filetypes = { 'cpp' },
  capabilities = capabilities,
}
vim.lsp.enable('clangd')
