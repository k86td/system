{ config, pkgs, ... }:
let
  username = "tlepine";
  homeDirectory = "/home/${username}";
in
{
  home.username = "${username}";
  home.homeDirectory = "${homeDirectory}";

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    openssh
    code-server
    gcc
    stow
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    "${homeDirectory}/.config/nvim" = {
      source = ./nvim;
      recursive = true;
    };
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  home.shellAliases = {
    sw = "home-manager --flake /etc/nixos#ebox-tlepine switch";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      source ~/.profile
      export LANG=C.UTF-8
    '';
    oh-my-zsh = {
      enable = true;
      theme = "half-life";
    };
  };

  programs.lazygit = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Tristan Lepine";
    userEmail = "tristan.lepine@ebox.ca";
  };

  programs.neovim = {
    enable = true;
  };
}

