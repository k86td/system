{
  inputs, lib, config, pkgs, ...
}:
let
  wal-darkeye = pkgs.stdenv.mkDerivation rec {
    name = "darkeye";
    src = files/wallpapers;
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out
      cp ${src}/darkeye.jpg $out
    '';
  };
  colors = {
    background = "#181C14";
    tertiary = "#3C3D37";
    secondary = "#697565";
    primary = "#ECDFCC";
  };
in {
  imports = [
    ./modules/terminal.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home.username = "tlepine";
  home.homeDirectory = "/home/tlepine";

  programs.vim = {
    enable = true;
    settings = {
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
    };
  };

  services.wlsunset = {
    enable = true;
    latitude = 45.34;
    longitude = -73.54 ;
  };

  # TODO: move this to its own module
  services.gnome-keyring.enable = true;
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = rec {
      modifier = "Mod4";
      terminal = "${pkgs.kitty}/bin/kitty";
      gaps.inner = 5;
      defaultWorkspace = "workspace number 1";
      output = {
        eDP-1 = {
          bg = "${wal-darkeye}/darkeye.jpg fill";
        };
      };
      keybindings = 
      let
        pactl = "${pkgs.pulseaudio}/bin/pactl";
      in
        lib.mkOptionDefault {
        "XF86AudioMute"        = "exec ${pactl} set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioRaiseVolume" = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMicMute"        = "exec ${pactl} set-sink-input-mute @DEFAULT_SINK@ toggle";
      };
      bars = [
        { command = "${pkgs.waybar}/bin/waybar"; }
      ];
      input = {
        "type:touchpad" = {
          tap = "enabled";
          drag = "enabled";
          natural_scroll = "enabled";
        };
      };
    };
    extraConfig = ''
      default_border pixel 2
    '';
  };

  programs.waybar = {
    enable = true;
    style = ''
      * {
        font-family: Hurmit Nerd Font;
        font-size: 1em;
        border: none;
        border-radius: 0;
      }

      window#waybar {
        color: ${colors.primary};
        background: ${colors.background};
      }

      #workspaces button {
        color: ${colors.tertiary};
        background: ${colors.background};
        padding-left: 3px;
        padding-right: 3px;
      }
      #workspaces button:hover {
        color: ${colors.secondary};
      }
      #workspaces button.visible {
        color: ${colors.primary};
      }

      #clock {
        margin-left: 1em;
      }

      #battery, #network, #pulseaudio {
        font-size: 1.25em; 
        margin-left: 0.2em;
        margin-right: 0.2em;
      }

      .modules-left {
        padding-left: 1em;
      }

      .modules-right {
        padding-right: 1em;
      }

      tooltip {
        background: ${colors.background};
        border-radius: 5px;
      }
    '';
    settings = [
      {
        layer = "top";
        position = "top"; 
        modules-left = [ "sway/workspaces" "sway/mode" ];
        modules-center = [ "sway/window" ];
        modules-right = [ "pulseaudio#output" "battery" "network" "clock" ];


        "pulseaudio#output" = {
          format = "{icon} ";
          tooltip-format = "{volume}% {desc}";
          format-icons = {
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
            default-muted = "󰖁";
            headphone = "󰋋";
            headphone-muted = "󰟎";
          };
        };
        "battery" = {
          bat = "BAT1"; 
          format = "{icon} ";
          format-icons = {
            default = [
              "󰂎"
              "󱊡"
              "󱊢"
              "󱊣"
            ];
            charging = [
              "󰢟"
              "󱊤"
              "󱊥"
              "󱊦"
            ];
          };
        };
        "network" = {
          format-wifi = "{icon} "; 
          tooltip-format = "{essid} ({signalStrength}%)";
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤨"
          ];
        };
        "clock" = {
          format = "{:%b %d, %H:%M}";
          tooltip-format = "{calendar}";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            format = {
              today = "<span color='${colors.primary}'><b><u>{}</u></b></span>";
              weeks = "<span color='${colors.secondary}'>{}</span>";
              days = "<span color='${colors.secondary}'>{}</span>";
              months = "<span color='${colors.primary}'>{}</span>";
            };
          };
        };
      } 
    ];
  };

  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    mako
    libnotify

    vscode

    go
    gopls

    waypipe

    telegram-desktop
  ];

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.phinger-cursors;
    name = "phinger-cursors-dark";
  };

  programs.git = {
    userName = "Tristan Lepine";
    userEmail = "tristanlepine14@gmail.com";
  };

  programs.firefox = {
    enable = true;
  };

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";

}
