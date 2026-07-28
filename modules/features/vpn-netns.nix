{ ... }:
let
  vpnNetnsModule =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.services.vpnNetns;
      ns = cfg.namespace;

      forwarderUnit = fwd: {
        name = "netns-forward-${toString fwd.hostPort}";
        value = {
          description = "Forward :${toString fwd.hostPort} into ${ns} netns :${toString fwd.nsPort}";
          bindsTo = [ "wg-${ns}.service" ];
          after = [ "wg-${ns}.service" ];
          wantedBy = [ "multi-user.target" ];
          path = [
            pkgs.socat
            pkgs.iproute2
          ];
          serviceConfig = {
            Type = "simple";
            Restart = "on-failure";
            RestartSec = 2;
            ExecStart = pkgs.writeShellScript "netns-forward-${toString fwd.hostPort}" ''
              exec socat \
                TCP-LISTEN:${toString fwd.hostPort},fork,reuseaddr,bind=${fwd.hostAddress} \
                EXEC:"ip netns exec ${ns} socat STDIO TCP\:127.0.0.1\:${toString fwd.nsPort}",nofork
            '';
          };
        };
      };
    in
    {
      options.services.vpnNetns = {
        enable = lib.mkEnableOption "network namespace with WireGuard VPN";

        namespace = lib.mkOption {
          type = lib.types.str;
          default = "vpn";
          description = "Name of the network namespace to create.";
        };

        wgConfPath = lib.mkOption {
          type = lib.types.path;
          description = ''
            Absolute path (outside the Nix store) to a wg-quick style config
            containing PrivateKey, Address, PublicKey, and Endpoint fields.
          '';
        };

        dns = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ "1.1.1.1" ];
          description = "Nameservers used inside the namespace.";
        };

        forwards = lib.mkOption {
          default = [ ];
          description = "TCP ports forwarded from the host default netns into the vpn netns via socat.";
          type = lib.types.listOf (
            lib.types.submodule {
              options = {
                hostPort = lib.mkOption { type = lib.types.port; };
                nsPort = lib.mkOption { type = lib.types.port; };
                hostAddress = lib.mkOption {
                  type = lib.types.str;
                  default = "0.0.0.0";
                };
              };
            }
          );
        };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
          iproute2
          wireguard-tools
          socat
        ];

        environment.etc."netns/${ns}/resolv.conf".text = lib.concatMapStrings (
          n: "nameserver ${n}\n"
        ) cfg.dns;

        networking.firewall.allowedTCPPorts = map (f: f.hostPort) cfg.forwards;

        systemd.services =
          {
            "netns-${ns}" = {
              description = "Network namespace: ${ns}";
              wantedBy = [ "multi-user.target" ];
              after = [ "network-pre.target" ];
              path = [ pkgs.iproute2 ];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = pkgs.writeShellScript "netns-${ns}-up" ''
                  set -eu
                  ip netns add ${ns} 2>/dev/null || true
                  ip -n ${ns} link set lo up
                '';
                ExecStop = pkgs.writeShellScript "netns-${ns}-down" ''
                  ip netns del ${ns} || true
                '';
              };
            };

            "wg-${ns}" = {
              description = "WireGuard tunnel inside ${ns} netns";
              bindsTo = [ "netns-${ns}.service" ];
              requires = [ "network-online.target" ];
              after = [
                "netns-${ns}.service"
                "network-online.target"
              ];
              wantedBy = [ "multi-user.target" ];
              path = [
                pkgs.iproute2
                pkgs.wireguard-tools
                pkgs.gawk
                pkgs.coreutils
              ];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = pkgs.writeShellScript "wg-${ns}-up" ''
                  set -eu
                  CONF=${cfg.wgConfPath}

                  PRIVKEY=$(awk -F' *= *' '/^PrivateKey/ {print $2; exit}' "$CONF")
                  ADDR=$(   awk -F' *= *' '/^Address/    {print $2; exit}' "$CONF")
                  PEER=$(   awk -F' *= *' '/^PublicKey/  {print $2; exit}' "$CONF")
                  ENDPT=$(  awk -F' *= *' '/^Endpoint/   {print $2; exit}' "$CONF")

                  if [ -z "$PRIVKEY" ] || [ -z "$ADDR" ] || [ -z "$PEER" ] || [ -z "$ENDPT" ]; then
                    echo "wg-${ns}: missing field in $CONF" >&2
                    exit 1
                  fi

                  KEYFILE=$(mktemp -p /run wg-${ns}.key.XXXXXX)
                  chmod 0400 "$KEYFILE"
                  printf '%s' "$PRIVKEY" > "$KEYFILE"

                  ip -n ${ns} link del wg0 2>/dev/null || true
                  ip -n ${ns} link add wg0 type wireguard

                  IFS=',' read -ra ADDRS <<< "$ADDR"
                  for a in "''${ADDRS[@]}"; do
                    a="''${a// /}"
                    ip -n ${ns} addr add "$a" dev wg0
                  done

                  ip netns exec ${ns} wg set wg0 \
                    private-key "$KEYFILE" \
                    peer "$PEER" endpoint "$ENDPT" \
                    allowed-ips 0.0.0.0/0,::/0 \
                    persistent-keepalive 25

                  ip -n ${ns} link set wg0 up
                  ip -n ${ns} route add default dev wg0 || true
                  ip -n ${ns} -6 route add default dev wg0 2>/dev/null || true

                  rm -f "$KEYFILE"
                '';
                ExecStop = pkgs.writeShellScript "wg-${ns}-down" ''
                  ip -n ${ns} link del wg0 || true
                '';
              };
            };
          }
          // lib.listToAttrs (map forwarderUnit cfg.forwards);
      };
    };
in
{
  flake.nixosModules.vpnNetns = vpnNetnsModule;
}
