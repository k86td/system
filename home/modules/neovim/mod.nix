{ config, pkgs, lib, ... }:
{
  programs.neovim = {
    enable = true;
    withNodeJs = true;

    plugins = with pkgs.vimPlugins; [
      lazy-vim

      # additional plugins that we want to install need to be specified here
      which-key-nvim
    ];

    extraLuaConfig = ''
      vim.g.mapleader = " "
      require("lazy").setup({
        performance = {
          reset_packpath = false,
          rtp = {
            reset = false,
          },
        },
        dev = {
          path = "${pkgs.vimUtils.packDir config.home-manager.users.tlepine.programs.neovim.finalPackage.passthru.packpathDirs}/pack/myNeovimPackages/start",
          patterns = {""},
        },
        install = {
          missing = false,
        },
        spec = {
          -- here's where you want to add plugins and stuffies
          {
            "folke/which-key.nvim",
            event = "VeryLazy",
            opts = {
              plugins = { spelling = true },
              defaults = {
                mode = { "n", "v" },
              },
            },
            config = function(_, opts)
              local wk = require("which-key")
              wk.setup(opts)
              wk.register(opts.defaults)
            end,
          },
        },
      })
    '';
  };


}
