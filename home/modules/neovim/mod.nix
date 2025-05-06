{ config, pkgs, lib, ... }:
{
  # TODO: install Ltex-ls for grammar correction
  programs.neovim = {
    enable = true;
    withNodeJs = true;

    plugins = with pkgs.vimPlugins; [
      lazy-nvim

      # additional plugins that we want to install need to be specified here
      which-key-nvim
      neo-tree-nvim
      flash-nvim
      toggleterm-nvim
    ];

    extraPackages = with pkgs; [
      lua-language-server
      ltex-ls
    ];

    extraLuaConfig = ''
      vim.g.mapleader = " "
      vim.opt.rtp:prepend("${pkgs.vimPlugins.lazy-nvim}")

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
        spec = {
          -- here's where you want to add plugins and stuffies
          -- { import = "plugins" },
          {
            "folke/which-key.nvim",
            event = "VeryLazy",
            keys = {
              {
                "<leader>e",
                "<cmd>Neotree toggle<cr>",
                desc = "Open neo-tree",
              },
              {
                "<leader>s",
                mode =  { "n", "x", "o" },
                function()
                  require("flash").jump()
                end,
                desc = "Toggle flash search",
              },
              {
                "<c-/>",
                desc = "Toggle terminal",
              },
            },
          },
          {
            "nvim-neo-tree/neo-tree.nvim",
            lazy = false,
          },
          {
            "folke/flash.nvim",
            event = VeryLazy,
          },
        },
      })

      -- TODO: move this to its own LSP plugin
      vim.lsp.config['luals'] = {
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
      }
      vim.lsp.enable('luals')

      vim.lsp.config['ltex'] = {
        cmd = { 'ltex-ls' },
        filetypes = { "typst", "markdown" },
        settings = {
          ltex = {
            language = "fr",
          },
        },
      }
      vim.lsp.enable('ltex')
    '';
  };

  xdg.configFile."nvim/lua" = {
    recursive = true;
    source = ./lua;
  };
}
