{ config, pkgs, ... }:
{

  programs.neovide = {
    enable = true;
  };

  home.sessionVariables = {
    # For command-line compilation and LSP
  };

  programs.neovim = {
    enable = true;
    withNodeJs = true;

    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      nvim-lspconfig
      kanagawa-nvim
      nvim-web-devicons
      mini-icons
      snacks-nvim
      nvim-treesitter-context
      gitsigns-nvim
      fidget-nvim

      claudecode-nvim

      # dependencies
      plenary-nvim
      nui-nvim

      # auto-completion
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path

      # additional plugins that we want to install need to be specified here
      lazygit-nvim
      twilight-nvim
      zen-mode-nvim
      which-key-nvim
      neo-tree-nvim
      flash-nvim
      toggleterm-nvim
      precognition-nvim
      # hardtime-nvim
      telescope-nvim
      nvim-treesitter.withAllGrammars
      autoclose-nvim
      nvim-surround
      conform-nvim
    ];

    extraPackages = with pkgs; [
      lua-language-server
      ltex-ls
      ripgrep
      lazygit
      claude-code
      pyright
      nixd

      # rust
      rust-analyzer
      cargo
      rustc

      # typescript/javascript/vue
      vtsls
      vue-language-server
    ];

    extraLuaConfig = ''
      -- Prepend lazy.nvim to runtime path (requires Nix interpolation)
      vim.opt.rtp:prepend("${pkgs.vimPlugins.lazy-nvim}")

      -- Neovide configuration
      if vim.g.neovide then
        vim.g.neovide_scale_factor = 0.75
        vim.o.guifont = "Hurmit Nerd Font:h14"
      end

      -- Setup lazy.nvim with Nix-specific paths
      require("lazy").setup({
        performance = {
          reset_packpath = false,
          rtp = {
            reset = false,
          },
        },
        dev = {
          path = "${pkgs.vimUtils.packDir config.programs.neovim.finalPackage.passthru.packpathDirs}/pack/myNeovimPackages/start",
          patterns = {""},
        },
        install = {
          missing = false,
        },
        spec = require("plugins.lazy"),
      })

      -- Load all other configuration from Lua modules
      require("config")
    '';
  };

  xdg.configFile."nvim/lua" = {
    recursive = true;
    source = ./lua;
  };
}
