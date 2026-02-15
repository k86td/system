{ ... }: {
  flake.nixosModules.mdns = {
    config = {
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
  };
}
