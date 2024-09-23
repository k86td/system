{
  inputs, lib, config, pkgs, ...
}:
{
  imports = [
    ./modules/tmux.nix
    ./modules/vim.nix
  ];

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
  ];

  home.file = {
    "/home/tlepine/.config/nvim" = {
      source = ./files/nvim;
      recursive = true;
    };
  };

  home.sessionPath = [
    "/home/tlepine/.cargo/bin"
  ];

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
      sw = "sudo nixos-rebuild --flake /etc/nixos#superthinker switch";
    };

    oh-my-zsh = {
      # bureau
      enable = true;
      theme = "afowler";
    };

    history.size = 10000;
  };
}
