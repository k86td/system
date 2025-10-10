-- Nix language server (nixd)
local capabilities = require('lsp.capabilities').capabilities

vim.lsp.config['nixd'] = {
  cmd = { 'nixd' },
  filetypes = { 'nix' },
  capabilities = capabilities,
  settings = {
    nixd = {
      formatting = {
        command = { "nixpkgs-fmt" },
      },
      options = {
        nixos = {
          expr = '(builtins.getFlake "/etc/nixos").nixosConfigurations.superthinker.options',
        },
        home_manager = {
          expr = '(builtins.getFlake "/etc/nixos").homeConfigurations."new-tlepine".options',
        },
      },
      diagnostic = {
        suppress = {
          "sema-escaping-with",
        },
      },
    },
  },
}
vim.lsp.enable('nixd')
