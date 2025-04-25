{ config, pkgs, lib, ... }:
{
  programs.neovim = {
    enable = true;
    withNodeJs = true;

    plugins = with pkgs.vimPlugins; [
      lazy-nvim

      # additional plugins that we want to install need to be specified here
      which-key-nvim
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
          { import = "plugins" },
        },
      })
    '';
  };

  xdg.configFile."nvim/lua" = {
    recursive = true;
    source = ./lua;
  };
}
