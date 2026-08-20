{ ... }: {
  flake.nixosModules.tailscale = { ... }: {
    services.tailscale = {
      enable = true;
      # UDP 41641 for direct (non-DERP) connections
      openFirewall = true;
    };
  };
}
