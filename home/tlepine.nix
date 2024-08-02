{
  inputs, lib, config, pkgs, ...
}:
{
  imports = [ ./modules/tmux.nix ];

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    nixd
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
