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

  # TODO: move this to its own module
  services.gnome-keyring.enable = true;
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = rec {
      modifier = "Mod4";
      terminal = "${pkgs.kitty}/bin/kitty";
      gaps.inner = 10;
      output = {
        eDP-1 = {
          bg = "${wal-darkeye}/darkeye.jpg fill";
        };
      };
    };
    extraConfig = ''
      default_border pixel 2
    '';
  };

  home.packages = with pkgs; [
    swaybg
    grim
    slurp
    wl-clipboard
    mako
  ];

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.phinger-cursors;
    name = "phinger-cursors-dark";
    size = 32;
  };

  programs.git = {
    userName = "Tristan Lepine";
    userEmail = "tristanlepine14@gmail.com";
  };

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";

}
