{ pkgs, ... }:
{
  programs.taskwarrior = {
    enable = true;
    colorTheme = "dark-256";
    package = pkgs.taskwarrior3;
  };
}
