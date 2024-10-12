{ pkgs, ... }:
{
  programs.nushell = {
    enable = true;
    package = pkgs.nushell;
  };

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
  };

}
