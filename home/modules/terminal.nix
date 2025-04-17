{ pkgs, lib, ... }:
{
  home.shellAliases = {
    "hw" = "home-manager switch --flake /etc/nixos#new-tlepine"; 
  };

  programs.zsh = {
    enable = true;
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "Hurmit Nerd Font Mono";
      package = pkgs.nerd-fonts.hurmit;
    };
    settings = {
      shell = "${pkgs.zsh}/bin/zsh";
      enable_audio_bell = false;
      background_opacity = "0.9";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = ''$hostname$directory$git_branch$git_status$kubernetes
$character$cmd_duration
      '';
      add_newline = false;
      character = {
        success_symbol = "[::](yellow)";
        error_symbol = "[:!](red)";
      };
      username = {
        disabled = false;
        show_always = true;
      };
      hostname = {
        ssh_only = false;
      };
      kubernetes = {
        disabled = false;
        format = "[󱃾 $context](yellow) ";
      };
    };
  };
}
