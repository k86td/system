-- Python language server
local capabilities = require('lsp.capabilities').capabilities

vim.lsp.config['qmlls'] = {
  capabilities = capabilities,
}
vim.lsp.enable('qmlls')
