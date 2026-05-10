{ ... }: {
  flake.nixosModules.mediaserver = { pkgs, ... }: {
    config = {
      services.qbittorrent = {
        enable = true;
        openFirewall = true;
      };

      services.jellyfin = {
        enable = true;
        openFirewall = true;
      };

      services.radarr = {
        enable = true;
        openFirewall = true;
      };

      services.prowlarr = {
        enable = true;
        openFirewall = true;
      };

      environment.systemPackages = with pkgs; [ vlc ];
    };
  };
}
