{ config, pkgs, ... }:
let
  username = "tlepine";
  homeDirectory = "/home/${username}";

  zsh-utilities = pkgs.fetchFromGitHub {
    owner = "k86td";
    repo = "zsh-utilities";
    rev = "main";
    sha256 = "sha256-e7rKVh63IJ0ErA/FTTbtDrJcHIL4YGtSCtC/BGp2En4=";
  };
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
    # ansible
    # python312
    # python312Packages.pip
    # python312Packages.jmespath
    # python312Packages.kubernetes
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
      custom = "${zsh-utilities}";
      theme = "half-kubernetes";
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
