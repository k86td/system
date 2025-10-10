-- Rust language server
local capabilities = require('lsp.capabilities').capabilities

vim.lsp.config['rust_analyzer'] = {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  capabilities = capabilities,
}
vim.lsp.enable('rust_analyzer')
