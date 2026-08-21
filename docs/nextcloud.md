# Nextcloud on lenoovo-pad

Nextcloud runs on `lenoovo-pad` and is reachable **only over Tailscale**, with a real
Let's Encrypt certificate issued to the tailnet name. Nothing is exposed to the LAN or
the internet.

```
client on tailnet ──wireguard──> tailscaled :443 (TLS, *.ts.net cert)
                                     │  tailscale serve --https=443
                                     ▼
                            nginx 127.0.0.1:80 ──> php-fpm ──> nextcloud
                                                       ├─ postgres (unix socket)
                                                       └─ redis    (unix socket)
```

| Piece | Where |
|---|---|
| Feature modules | `modules/features/nextcloud.nix`, `modules/features/tailscale.nix` |
| Host wiring | `modules/hosts/lenoovo-pad.nix`, `hosts/lenoovo-pad/configuration.nix` |
| Nextcloud version | `pkgs.nextcloud32` (pinned explicitly — see below) |
| App + data | `/var/lib/nextcloud` → `/persist/var/lib/nextcloud` |
| Database | PostgreSQL, `/persist/var/lib/postgresql` |
| Cache/locking | Redis (`redis-nextcloud`), `/persist/var/lib/redis-nextcloud` |
| Admin secret | `/persist/secrets/nextcloud-admin-pass` (out of the nix store) |
| TLS front end | `systemd.services.tailscale-serve-nextcloud` |

## First-time setup

These three steps cannot be declared in Nix.

### 1. Enable HTTPS certificates on the tailnet

Admin console → https://login.tailscale.com/admin/dns → **HTTPS Certificates** → Enable.
Without this, `tailscale serve --https=443` cannot get a certificate.

### 2. Create the admin password file (before the first `nixos-rebuild switch`)

```bash
sudo install -d -m 0700 /persist/secrets
printf '%s' 'SOME-STRONG-PASSWORD' | sudo tee /persist/secrets/nextcloud-admin-pass >/dev/null
sudo chmod 0400 /persist/secrets/nextcloud-admin-pass
```

The file is read once, to seed the `tlepine` admin account. Editing it later does **not**
change the password — use `sudo -u nextcloud nextcloud-occ user:resetpassword tlepine`.

### 3. Join the tailnet and set the hostname

`services.nextcloud.hostName` in `hosts/lenoovo-pad/configuration.nix` ships with a
placeholder, because the MagicDNS suffix is only known after the node logs in. So deploy
tailscale first:

```bash
sudo nixos-rebuild switch --flake github:k86td/system#lenoovo-pad --refresh
sudo tailscale up
tailscale status --json | jq -r .MagicDNSSuffix   # -> tailXXXX.ts.net
```

Put `lenoovo-pad.<suffix>` into `services.nextcloud.hostName`, commit, and rebuild.

To make this hands-off later, drop a pre-authorised key in
`/persist/secrets/tailscale-authkey` and set `services.tailscale.authKeyFile` in
`modules/features/tailscale.nix`.

## Checks

```bash
systemctl status postgresql nextcloud-setup phpfpm-nextcloud nginx \
                 redis-nextcloud tailscale-serve-nextcloud
tailscale serve status            # https://lenoovo-pad.<tailnet>.ts.net -> 127.0.0.1:80
sudo -u nextcloud nextcloud-occ status
curl -sI -H 'Host: lenoovo-pad.<tailnet>.ts.net' http://127.0.0.1/status.php
ss -lntp | grep ':80'             # must be 127.0.0.1:80 only
```

If `tailscale-serve-nextcloud` is failing, it is almost always one of: the node is not
logged in yet, or HTTPS certificates are not enabled on the tailnet (step 1). The unit
retries every 30s, so fixing either one resolves it without a rebuild.

`tailscale serve` config lives in `/var/lib/tailscale`, which is persisted, so the
mapping survives reboots.

## Notes

- **Version pinning is mandatory.** The NixOS module picks its default from
  `system.stateVersion`, and `24.11` maps to `nextcloud30`, which no longer exists in
  nixpkgs. `package = pkgs.nextcloud32` is set explicitly. Nextcloud only supports
  one-major-at-a-time upgrades, so the next bump is 32 → 33 — never skip a major.
- **`memory_limit` is forced to 1G.** The module otherwise sets it to `maxUploadSize`
  (4G), which is far too much for a 7.5G box that also transcodes.
- **`php-fpm` pool is trimmed** to 32 children; the module default (120) assumes a
  dedicated server.
- **Media is deliberately separate.** The `nextcloud` user is not in the `media` group
  and `/persist/media` is not mounted into Nextcloud. Add it from Settings →
  External storage if that changes.
- **No backups yet.** `/persist` has no snapshot or off-site story. Worth fixing now
  that real data lives there.
