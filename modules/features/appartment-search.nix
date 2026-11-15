{ inputs, ... }:
{
  flake.nixosModules.appartment-search = {
    imports = [ inputs.appartment-search.nixosModules.default ];

    services.appartment-search = {
      enable = true;
      tailscale.enable = true;
      schedule = "*-*-* 00/3:00:00";
      settings.trajets.destinations = [
        {
          nom = "ULaval";
          lat = 46.77866;
          lng = -71.27458;
        }
        {
          nom = "Travail";
          lat = 46.81559;
          lng = -71.26786;
        }
      ];
    };
  };
}
