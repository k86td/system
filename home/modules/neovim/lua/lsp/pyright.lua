-- Python language server
local capabilities = require('lsp.capabilities').capabilities

vim.lsp.config['pyright'] = {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  capabilities = capabilities,
}
vim.lsp.enable('pyright')
