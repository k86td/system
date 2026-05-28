{ ... }: {
  flake.nixosModules.homelab = { pkgs, ... }: {
    config = {
      services.home-assistant = {
        enable = true;
        openFirewall = true;
        config = {
          homeassistant = {
            name = "Home";
            unit_system = "metric";
            time_zone = "America/Toronto";
          };
          default_config = { };
        };
      };

      services.tailscale = {
        enable = true;
        openFirewall = true;
      };
    };
  };
}
