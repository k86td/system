-- Go language server
local capabilities = require('lsp.capabilities').capabilities

vim.lsp.config['gopls'] = {
  cmd = { 'gopls' },
  filetypes = { 'go' },
  capabilities = capabilities,
}
vim.lsp.enable('gopls')
