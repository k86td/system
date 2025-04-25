{ config, pkgs, lib, ... }:
{
  programs.neovim = {
    enable = true;
    withNodeJs = true;

    plugins = with pkgs.vimPlugins; [
      lazy-vim
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
        },
        install = {
          missing = false,
        },
      })
    '';
  };
}
