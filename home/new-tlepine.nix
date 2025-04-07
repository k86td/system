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
in {
  imports = [
    ./modules/terminal.nix
  ];

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

  # TODO: move this to its own module
  services.gnome-keyring.enable = true;
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = rec {
      modifier = "Mod4";
      terminal = "${pkgs.kitty}/bin/kitty";
      gaps.inner = 10;
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
      };
    };
    extraConfig = ''
      default_border pixel 2
    '';
  };

  # programs.waybar = {
  #   enable = true;
  #   settings = {};
  #   style = {};
  # };

  home.packages = with pkgs; [
    swaybg
    grim
    slurp
    wl-clipboard
    mako

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
