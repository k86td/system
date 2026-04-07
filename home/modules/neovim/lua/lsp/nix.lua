-- Nix language server (nixd)
local capabilities = require('lsp.capabilities').capabilities

vim.lsp.config['nil_ls'] = {
  cmd = { 'nil' },
  filetypes = { 'nix' },
  capabilities = capabilities,
  settings = {
    ["nil"] = {
      flake = {
        autoArchive = true,
        autoEvalInputs = true
      },
      formatting = {
        command = { "nixfmt" }
      },
      nix = {
        binary = "nix"
      }
    }
  },
}
vim.lsp.enable('nil_ls')
