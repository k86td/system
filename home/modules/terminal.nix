{ pkgs, lib, ... }:
{
  programs.zsh = {
    enable = true;
    initContent = ''
      unsetopt BEEP
      bindkey -e

      # Key bindings for special keys
      bindkey "^[[1;5C" forward-word           # Ctrl+Right
      bindkey "^[[1;5D" backward-word          # Ctrl+Left
      bindkey "^[[3~" delete-char              # Delete
      bindkey "^[[H" beginning-of-line         # Home
      bindkey "^[[F" end-of-line               # End
      bindkey "^[[1~" beginning-of-line        # Home (alternate)
      bindkey "^[[4~" end-of-line              # End (alternate)
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
        opacity = 0.7;
        blur = true;
        dynamic_title = true;
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
      colors = {
        primary = {
          background = "#1c1b19";
          foreground = "#fce8c3";
        };
        cursor = {
          text = "CellBackground";
          cursor = "#fbb829";
        };
        normal = {
          black = "#1c1b19";
          red = "#ef2f27";
          green = "#519f50";
          yellow = "#fbb829";
          blue = "#2c78bf";
          magenta = "#e02c6d";
          cyan = "#0aaeb3";
          white = "#baa67f";
        };
        bright = {
          black = "#918175";
          red = "#f75341";
          green = "#98bc37";
          yellow = "#fed06e";
          blue = "#68a8e4";
          magenta = "#ff5c8f";
          cyan = "#2be4d0";
          white = "#fce8c3";
        };
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
    settings = {
      format = ''$hostname$directory$git_branch$git_status$kubernetes$nix_shell
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
      nix_shell = {
        disabled = false;
        symbol = "✦ ";
      };
    };
  };
}
