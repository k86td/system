{ ... }:
{
  flake.nixosModules.nextcloud =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = {
        services.nextcloud = {
          # Must be explicit: the module derives its default from system.stateVersion,
          enable = true;

          # and 24.11 maps to nextcloud30, which no longer exists in nixpkgs.
          package = pkgs.nextcloud32;

          # `hostName` is the full MagicDNS name and is set per-host — it is only known
          # once the node has joined the tailnet.
          hostName = "lenoovo-pad.caracal-bellatrix.ts.net";

          # TLS is terminated by tailscaled in front of nginx, so Nextcloud never sees
          # https itself and has to be told the public scheme.
          https = true;

          config = {
            dbtype = "pgsql";
            adminuser = "tlepine";
            adminpassFile = "/persist/secrets/nextcloud-admin-pass";
          };
          database.createLocally = true;

          # APCu for the local cache, Redis over a unix socket for file locking.
          configureRedis = true;

          maxUploadSize = "4G";
          # The module sets memory_limit = maxUploadSize unconditionally, which would hand
          # PHP 4G on a 7.5G box — override it.
          phpOptions."memory_limit" = lib.mkForce "1G";

          # Replaces the default wholesale, so the non-sizing keys are repeated here.
          # The defaults assume a dedicated 4G server (120 children); this box also transcodes.
          poolSettings = {
            pm = "dynamic";
            "pm.max_children" = "32";
            "pm.start_servers" = "4";
            "pm.min_spare_servers" = "2";
            "pm.max_spare_servers" = "8";
            "pm.max_requests" = "500";
            "pm.status_path" = "/status";
          };

          autoUpdateApps.enable = true;

          settings = {
            overwriteprotocol = "https";
            trusted_proxies = [
              "127.0.0.1"
              "::1"
            ];
            default_phone_region = "CA";
          };
        };

        # Only reachable through `tailscale serve`; nothing binds the Wi-Fi interface and
        # no firewall port is opened.
        services.nginx.virtualHosts.${config.services.nextcloud.hostName}.listen = [
          {
            addr = "127.0.0.1";
            port = 80;
          }
        ];

        systemd.services.tailscale-serve-nextcloud = {
          description = "Serve Nextcloud over Tailscale HTTPS";
          after = [
            "tailscaled.service"
            "nginx.service"
          ];
          wants = [
            "tailscaled.service"
            "nginx.service"
          ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pkgs.tailscale}/bin/tailscale serve --bg --https=443 http://127.0.0.1:80";
            ExecStop = "${pkgs.tailscale}/bin/tailscale serve --https=443 off";
            # Keeps retrying until the node is logged in and HTTPS certs are enabled.
            Restart = "on-failure";
            RestartSec = 30;
          };
        };

        # impermanence creates the backing dirs as root:root otherwise.
        systemd.tmpfiles.rules = [
          "d /persist/var/lib/nextcloud       0750 nextcloud       nextcloud       - -"
          "d /persist/var/lib/postgresql      0750 postgres        postgres        - -"
          # The redis instance runs as nextcloud:nextcloud (services.redis.servers.<name>.group
          # defaults to .user, so no redis-nextcloud user or group is ever created), but its
          # StateDirectory is still named redis-nextcloud.
          "d /persist/var/lib/redis-nextcloud 0700 nextcloud       nextcloud       - -"
        ];
      };
    };
}
