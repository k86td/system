{ inputs, ... }: {
  flake.nixosModules.mediaserver = { pkgs, lib, ... }: {
    imports = [ inputs.self.nixosModules.vpnNetns ];

    config = {
      services.vpnNetns = {
        enable = true;
        wgConfPath = "/persist/secrets/surfshark-wg.conf";
        dns = [ "162.252.172.57" "149.154.159.92" ];
        forwards = [ { hostPort = 8080; nsPort = 8080; } ];
      };

      systemd.services.qbittorrent = {
        bindsTo = [ "wg-vpn.service" ];
        after   = [ "wg-vpn.service" ];
        serviceConfig = {
          NetworkNamespacePath = "/var/run/netns/vpn";
          RestrictNamespaces   = false;
        };
      };

      services.qbittorrent = {
        enable = true;
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

      services.sonarr = {
        enable = true;
        openFirewall = true;
      };

      services.flaresolverr = {
        enable = true;
        openFirewall = true;
      };

      users.groups.media = { };
      users.users.jellyfin.extraGroups = [ "media" ];
      users.users.qbittorrent.extraGroups = [ "media" ];
      users.users.sonarr.extraGroups = [ "media" ];
      users.users.radarr.extraGroups = [ "media" ];

      systemd.tmpfiles.rules = [
        "d /persist/media          0775 root media - -"
        "d /persist/media/shows    0775 root media - -"
        "d /persist/media/movies   0775 root media - -"
        "d /persist/media/download 0775 root media - -"
      ];

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
          sonarr = pkgs.writeText "sonarr.service" ''
            <?xml version="1.0" standalone='no'?>
            <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
            <service-group>
              <name replace-wildcards="yes">Sonarr on %h</name>
              <service>
                <type>_http._tcp</type>
                <port>8989</port>
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
          flaresolverr = pkgs.writeText "flaresolverr.service" ''
            <?xml version="1.0" standalone='no'?>
            <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
            <service-group>
              <name replace-wildcards="yes">FlareSolverr on %h</name>
              <service>
                <type>_http._tcp</type>
                <port>8191</port>
              </service>
            </service-group>
          '';
        };
      };
    };
  };
}
