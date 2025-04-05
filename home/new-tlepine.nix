{
  inputs, lib, config, pkgs, ...
}:
{
  imports = [ ];

  home.username = "tlepine";
  home.homeDirectory = "/home/tlepine";

  # TODO: move this to its own module
  services.gnome-keyring.enable = true;
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = rec {
      modifier = "Mod4";
      gaps.inner = 10;
      output = {
        eDP-1 = {
          bg = "/etc/nixos/home/files/wallpapers/darkeye.jpg fill";
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
