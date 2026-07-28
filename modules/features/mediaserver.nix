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

      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
        publish = {
          enable = true;
          addresses = true;
          userServices = true;
        };
        extraServiceFiles = {
          jellyfin = pkgs.writeText "jellyfin.service" ''
            <?xml version="1.0" standalone='no'?>
            <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
            <service-group>
              <name replace-wildcards="yes">Jellyfin on %h</name>
              <service>
                <type>_http._tcp</type>
                <port>8096</port>
              </service>
            </service-group>
          '';
          radarr = pkgs.writeText "radarr.service" ''
            <?xml version="1.0" standalone='no'?>
            <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
            <service-group>
              <name replace-wildcards="yes">Radarr on %h</name>
              <service>
                <type>_http._tcp</type>
                <port>7878</port>
              </service>
            </service-group>
          '';
          prowlarr = pkgs.writeText "prowlarr.service" ''
            <?xml version="1.0" standalone='no'?>
            <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
            <service-group>
              <name replace-wildcards="yes">Prowlarr on %h</name>
              <service>
                <type>_http._tcp</type>
                <port>9696</port>
              </service>
            </service-group>
          '';
          qbittorrent = pkgs.writeText "qbittorrent.service" ''
            <?xml version="1.0" standalone='no'?>
            <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
            <service-group>
              <name replace-wildcards="yes">qBittorrent on %h</name>
              <service>
                <type>_http._tcp</type>
                <port>8080</port>
              </service>
            </service-group>
          '';
        };
      };
    };
  };
}
