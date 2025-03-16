{
  inputs, lib, config, pkgs, ...
}:
{
  imports = [
    ./modules/tmux.nix
    ./modules/vim.nix
    ./modules/nushell.nix
    ./modules/lazyvim/mod.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  # xdg.portal = {
  #   enable = true;
  #   config.common.default = "hyprland";
  #   extraPortals = [
  #     pkgs.xdg-desktop-portal-hyprland
  #   ];
  # };

  services.dunst = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    wdisplays
    nixd
    fzf
    ripgrep
    rustup
    pkg-config
    kubectl
    blender
    obs-studio
    xorg.xset
    gopls
    netbeans
    libreoffice
    httpie
    halloy
    vtsls
    cargo-generate
    sc
    waypipe

    # neovim lazyvim deps
    go
    gopls
    gofumpt
    gotools
    shfmt
    stylua

    dart
    # games
    runelite
  ];

  home.file = {
    # "/home/tlepine/.config/nvim" = {
    #   source = ./files/nvim;
    #   recursive = true;
    # };
    "/home/tlepine/.config/starship.toml" = {
        source = ./files/starship.toml;
    };
  };

  home.sessionPath = [
    "/home/tlepine/.cargo/bin"
  ];

  programs.nushell = {
    shellAliases = {
      start = "Hyprland";
      sw = "sudo nixos-rebuild --flake /etc/nixos#superthinker switch";
      kins = "kubectl --insecure-skip-tls-verify";
      vi = "vim";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initExtra = ''
      path+=('/home/tlepine/go/bin')
      export TERM=xterm-256color

      source <(kubectl completion zsh)
    '';

    shellAliases = {
      start = "Hyprland && logout";
      sw = "sudo nixos-rebuild --flake /etc/nixos#superthinker switch";
      kins = "kubectl --insecure-skip-tls-verify";
    };

    oh-my-zsh = {
      # bureau
      enable = true;
      theme = "afowler";
    };

    history.size = 10000;
  };
}
