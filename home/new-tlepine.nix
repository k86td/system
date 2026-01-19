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
        pkgs.xdg-desktop-portal-gnome
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

  services.swayidle = {
    enable = true;
    events = [
      { 
        event = "before-sleep"; 
        command = "${pkgs.quickshell}/bin/qs -c dms ipc call lock lock"; 
      }
      { 
        event = "lock"; 
        command = "${pkgs.quickshell}/bin/qs -c dms ipc call lock lock"; 
      }
    ];
    timeouts = [
      { 
        timeout = 300; 
        command = "${pkgs.quickshell}/bin/qs -c dms ipc call lock lock"; 
      }
      { 
        timeout = 600; 
        command = "${pkgs.systemd}/bin/systemctl suspend"; 
      }
    ];
  };

  services.kanshi = {
    enable = true;
    settings = [
      { profile.name = "television";
        profile.outputs = [
          { criteria = "eDP-1";
            scale = 2.0;
            mode = "1920x1080@60";
            position = "0,270";
          }
          { criteria = "Planar Systems, Inc. SLM65 0x01010101";
            scale = 1.0;
            mode = "1920x1080@60";
            position = "1920,0";
          }
        ];
      }
      { profile.name = "television";
        profile.outputs = [
          { criteria = "eDP-1";
            scale = 2.0;
            mode = "1920x1080@60";
            position = "0,270";
          }
          { criteria = "Toshiba America Info Systems Inc TOSHIBA-TV 0x01010101";
            scale = 1.0;
            mode = "1920x1080@60";
            position = "1920,0";
          }
        ];
      }
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
  xdg.configFile."niri/config.kdl".source = ./files/niri/config.kdl;
  xdg.configFile."niri/dms-binds.kdl".source = ./files/niri/dms-binds.kdl;

  # TODO: move this to its own module
  services.gnome-keyring.enable = true;

  home.sessionVariables = {
    ELECTRON_ENABLE_SYSTEM_DIALOGS = "1";
    GTK_USE_PORTAL = "1";
  };

  home.packages = with pkgs; [
    xdg-desktop-portal-wlr

    inputs.claude-desktop.packages.${system}.claude-desktop-with-fhs
    uv
    logseq
    ticktick
    appimage-run
    capacities
    fuzzel
    quickshell
    xwayland-satellite

    postman
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
    ninja
    gcc-arm-embedded

    go
    gopls
    gotools

    zig
    zls


    terraform-ls

    nixfmt-classic

    waypipe

    discord
    telegram-desktop

    # work
    teams-for-linux

    # reMarkable
    rmapi

    # writing/PDF
    zathura
    typst

    runelite
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
