-- Nix language server
local capabilities = require('lsp.capabilities').capabilities

vim.lsp.config['nil_ls'] = {
  cmd = { 'nil' },
  filetypes = { 'nix' },
  capabilities = capabilities,
}
vim.lsp.enable('nil_ls')
