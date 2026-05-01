-- Python language server
local capabilities = require('lsp.capabilities').capabilities

vim.lsp.config['qmlls'] = {
  cmd = { 'qmlls', '-E' },
  capabilities = capabilities,
}
vim.lsp.enable('qmlls')
