{
  inputs, lib, config, pkgs, ...
}:
{
  imports = [ ];

  home.username = "tlepine";
  home.homeDirectory = "/home/tlepine";

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.phinger-cursors;
    name = "phinger-cursors-dark";
    size = 32;
  };

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";

}
