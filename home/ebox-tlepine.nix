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
rec {
  imports = [
    ./modules/tmux.nix
    ./modules/vim.nix
    ./modules/taskwarrior.nix
    ./modules/nushell.nix
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
    "${homeDirectory}/.config/starship.toml" = {
        source = ./files/starship.toml;
    };
  };

  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  home.shellAliases = {
    sw = "home-manager --flake /etc/nixos#ebox-tlepine switch";
    dev = "nix develop -c $SHELL";
  };

  programs.nushell = {
    shellAliases = {
      sw = "home-manager --flake /etc/nixos#ebox-tlepine switch";
      dev = "nix develop -c $env.SHELL";
    };
    extraConfig = ''
      $env.STARSHIP_SHELL = "nu"

      def create_left_prompt [] {
          starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
      }

      # Use nushell functions to define your right and left prompt
      $env.PROMPT_COMMAND = { || create_left_prompt }
      $env.PROMPT_COMMAND_RIGHT = ""

      # The prompt indicators are environmental variables that represent
      # the state of the prompt
      $env.PROMPT_INDICATOR = ""
      $env.PROMPT_INDICATOR_VI_INSERT = ": "
      $env.PROMPT_INDICATOR_VI_NORMAL = "〉"
      $env.PROMPT_MULTILINE_INDICATOR = "::: "

      $env.PATH = '/home/tlepine/.nix-profile/bin'
    '';
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
