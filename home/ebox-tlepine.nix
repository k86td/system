{ config, pkgs, ... }:
let
  username = "tlepine";
  homeDirectory = "/home/${username}";
in
{
  imports = [
    ./modules/tmux.nix
    ./modules/vim.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  home.username = "${username}";
  home.homeDirectory = "${homeDirectory}";

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    lua-language-server

    openssh
    code-server
    gcc
    stow
    kubectl
    kubelogin-oidc
    k9s

    nixd

    # to move to ansible-k3s
    ansible
    python312Packages.pip
    python312Packages.jmespath
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    "${homeDirectory}/.config/nvim" = {
      source = ./files/nvim;
      recursive = true;
    };
    "${homeDirectory}/.config/nix" = {
        source = ./files/nix;
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
