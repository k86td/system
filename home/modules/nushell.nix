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
}
