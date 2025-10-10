-- LSP capabilities configuration
-- This module exports the default capabilities for LSP servers

local M = {}

-- Get default capabilities from nvim-cmp if available
local has_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if has_cmp then
  M.capabilities = cmp_nvim_lsp.default_capabilities()
else
  M.capabilities = vim.lsp.protocol.make_client_capabilities()
end

return M
