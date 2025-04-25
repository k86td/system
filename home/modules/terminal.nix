{ pkgs, lib, ... }:
{
  home.shellAliases = {
    "hw" = "home-manager switch --flake /etc/nixos#new-tlepine"; 
  };

  programs.zsh = {
    enable = true;
    initExtra = ''
      unsetopt BEEP
      bindkey -e
    '';
    enableCompletion = true;
    historySubstringSearch.enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.ripgrep = {
    enable = true;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = 0.9;
        blur = true;
      };
      terminal.shell = {
        program = "${pkgs.zsh}/bin/zsh";
      };
      font = {
        size = 14;
        normal = {
          family = "Hurmit Nerd Font";
          style = "Bold";
        };
      };
      general = {
        import = [
          "${pkgs.alacritty-theme}/share/alacritty-theme/hyper.toml"
        ];
      };
    };
  };

  programs.kitty = {
    enable = false;
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
