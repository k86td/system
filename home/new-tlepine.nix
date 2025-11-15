{ cfg, lib, pkgs, inputs, ... }:
{
  imports = [
    ./modules/terminal.nix
    ./modules/vim.nix
    ./modules/neovim
    ./modules/1password.nix
    ./modules/tmux.nix

    inputs.zen-browser.homeModules.beta
  ];

  nixpkgs.config.allowUnfree = true;

  home.username = "tlepine";
  home.homeDirectory = "/home/tlepine";
  home.shellAliases = {
    hw = "home-manager switch --flake /etc/nixos#new-tlepine";
  };

  programs.zen-browser.enable = true;

  xdg = {
    enable = true;
    portal = {
      enable = true;
      config = {
        common = {
          default = [
            "gtk"
          ];
        };
      };
      extraPortals = [
        pkgs.xdg-desktop-portal-wlr
      ];
    };
  };

  services.wlsunset = {
    enable = true;
    latitude = 45.34;
    longitude = -73.54 ;
  };

  programs.wofi = {
    enable = false;
    # this can be helpful when debugging
    # settings = {
    #   "drun-print_command" = true;
    # };
  };

  programs.rofi = {
    enable = true;
    theme = ./files/rofi/redSquared.rasi;
    package = pkgs.rofi;
  };

  services.kanshi = {
    enable = true;
    settings = [
      { profile.name = "undocked";
        profile.outputs = [
          { criteria = "eDP-1";
            scale = 1.0;
            mode = "1920x1080@60";
            position = "0,0";
          }
        ];
      }
      { profile.name = "docked-single-left";
        profile.outputs = [
          { criteria = "eDP-1";
            scale = 1.0;
            mode = "1920x1080@60";
            position = "0,270";
          }
          { criteria = "LG Electronics 32inch LG FHD 903NTRLA7270";
            mode = "1920x1080@60";
            position = "1920,0";
          }
        ];
      }
      # this profile is when I restart my laptop & DP-* have their original values
      { profile.name = "plug-replug-dual-monitor";
        profile.outputs = [
          {
            criteria = "DP-5";
            position = "0,0";
          }
          {
            criteria = "DP-4";
            position = "1920,0";
            transform = "270";
          }
          {
            criteria = "eDP-1";
            position = "3000,840";
            scale = 2.0;
          }
        ];
      }
      # this profile is when I plug back USB-C dock and DP-* are all fucked
      { profile.name = "plug-replug-dual-monitor";
        profile.outputs = [
          {
            criteria = "DP-7";
            position = "0,0";
          }
          {
            criteria = "DP-6";
            position = "1920,0";
            transform = "270";
          }
          {
            criteria = "eDP-1";
            position = "3000,840";
            scale = 2.0;
          }
        ];
      }
      { profile.name = "docked-external-monitor";
        profile.outputs = [
          { criteria = "eDP-1";
            scale = 1.0;
            mode = "1920x1080@60";
            position = "1920,0";
          }
          { criteria = "BOE Display L56051794302";
            mode = "1920x1080@60";
            position = "0,270";
          }
        ];
      }
    ];
  };

  # TODO: move this to its own module
  services.gnome-keyring.enable = true;
  wayland.windowManager.sway = {
    enable = true;
    checkConfig = false;
    package = pkgs.swayfx;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      export ELECTRON_OZONE_PLATFORM_HINT=wayland
    '';
    config = rec {
      modifier = "Mod4";
      terminal = "${pkgs.alacritty}/bin/alacritty";
      gaps.inner = 5;
      defaultWorkspace = "workspace number 1";
      startup = [
        {
          command = "${pkgs.kanshi}";
          always = true;
        }
      ];
      output = {
        eDP-1 = {
          bg = "${cfg.wallpapers.darkeye.imgJpg}/img.jpg fill";
        };

        "BOE Display L56051794302" = {
          bg = "${cfg.wallpapers.grayabstract.imgPng}/img.png fill";
        };

        "LG Electronics 32inch LG FHD 903NTRLA7270" = {
          bg = "${cfg.wallpapers.grayabstract.imgPng}/img.png fill";
        };

        "Acer Technologies V277 TC0AA0018522" = {
          bg = "${cfg.wallpapers.grayabstract.imgPng}/img.png fill";
        };
      };
      keybindings = 
      let
        pactl = "${pkgs.pulseaudio}/bin/pactl";
        brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
      in
        lib.mkOptionDefault {
        "XF86AudioMute"         = "exec ${pactl} set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioRaiseVolume"  = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume"  = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMicMute"      = "exec ${pactl} set-sink-input-mute @DEFAULT_SINK@ toggle";

        "XF86MonBrightnessUp"   = "exec ${brightnessctl} set +5%";
        "XF86MonBrightnessDown" = "exec ${brightnessctl} set 5%-";

        "Mod4+d" = "exec ${pkgs.rofi}/bin/rofi -show drun -monitor -5";
        "Mod4+period" = "exec ${pkgs.rofimoji}/bin/rofimoji";
      };
      bars = [
        { command = "${pkgs.waybar}/bin/waybar"; }
      ];
      input = {
        "type:keyboard" = {
          xkb_layout = "us,ca";
          xkb_options = "grp:win_space_toggle";
        };

        "type:touchpad" = {
          tap = "enabled";
          drag = "enabled";
          natural_scroll = "enabled";
          accel_profile = "flat";
        };
        "1118:2354:Microsoft_Arc_Mouse" = {
          pointer_accel = "-0.7";
        };
      };
    };
    extraConfig = ''
      default_border none
      hide_edge_borders --i3 smart
      smart_borders on
      smart_gaps on

      # swayfx
      blur enable
      blur_xray disable
      blur_passes 3
      blur_radius 8

      for_window [floating] blur enable
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
        color: ${cfg.wallpapers.darkeye.colors.primary};
        background: ${cfg.wallpapers.darkeye.colors.background};
      }

      #workspaces button {
        color: ${cfg.wallpapers.darkeye.colors.tertiary};
        background: ${cfg.wallpapers.darkeye.colors.background};
        padding-left: 3px;
        padding-right: 3px;
      }
      #workspaces button:hover {
        color: ${cfg.wallpapers.darkeye.colors.secondary};
      }
      #workspaces button.visible {
        color: ${cfg.wallpapers.darkeye.colors.primary};
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
        background: ${cfg.wallpapers.darkeye.colors.background};
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
          bat = "BAT0"; 
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
              today = "<span color='${cfg.wallpapers.darkeye.colors.primary}'><b><u>{}</u></b></span>";
              weeks = "<span color='${cfg.wallpapers.darkeye.colors.secondary}'>{}</span>";
              days = "<span color='${cfg.wallpapers.darkeye.colors.secondary}'>{}</span>";
              months = "<span color='${cfg.wallpapers.darkeye.colors.primary}'>{}</span>";
            };
          };
        };
      } 
    ];
  };

  home.sessionVariables = {
    ELECTRON_ENABLE_SYSTEM_DIALOGS = "1";
    GTK_USE_PORTAL = "1";
  };

  home.packages = with pkgs; [
    xdg-desktop-portal-wlr

    ticktick

    obsidian
    vlc
    lazygit

    grim
    slurp
    wl-clipboard
    mako
    libnotify
    claude-code
    brave

    inkscape
    inkscape-extensions.textext

    # minimal browser with vim-like bindings
    nyxt

    gcr

    # rust
    pkg-config
    openssl
    rustup
    codecrafters-cli
    # rust-analyzer
    # cargo
    # rustc
    # rustfmt

    vscode
    kubectl

    go
    gopls
    gotools

    terraform-ls

    nixfmt-classic

    waypipe

    discord
    telegram-desktop

    # work
    teams-for-linux

    # writing/PDF
    zathura
    typst
  ];

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.phinger-cursors;
    name = "phinger-cursors-dark";
  };

  programs.git = {
    enable = true;
    userName = "Tristan Lepine";
    userEmail = "tristanlepine14@gmail.com";
  };

  programs.firefox = {
    enable = true;
  };

  programs.chromium = {
    enable = true;
    extensions = [
      "aeblfdkhhhdcdjpifhhbdiojplfjncoa"
    ];
  };

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";

}
