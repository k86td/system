{ pkgs, lib, ... }:
{
  programs.zsh = {
    enable = true;
  };

  programs.kitty = {
    enable = true;
    settings = {
      shell = "${pkgs.zsh}/bin/zsh";
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
