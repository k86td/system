# lenoovo-pad → homelab conversion

Session log + resume plan. Started as Lenovo IdeaPad S540 (i7-8565U, 7.5G RAM, 931G NVMe, Wi-Fi only — no ethernet port) running NixOS desktop. Goal: headless homelab.

## Current state

- **Install completed** via `disko + nixos-install` from kexec installer.
- **Boot fails**: BIOS shows "no bootable devices found" after reboot.
- Diagnosis pending — likely systemd-boot/ESP issue or firmware boot order.
- Disk wiped. Old NixOS gone. Cannot SSH back into lenoovo-pad until boot fixed.

## Goal (decided)

Headless homelab on impermanence (tmpfs root, persist-whitelist). Services:

- `home-assistant` (port 8123) — minimal start
- `tailscale` — free tier, mesh VPN, 2 nodes (lenoovo-pad + future RPi)
- `podman` — containers (existing module)
- `caches` — existing nix caches module

Stripped from old desktop config: greetd, sway, pipewire, hardware.graphics, fonts, user GUI packages, GRUB → systemd-boot.

## Architecture decisions

| Decision | Choice | Why |
|---|---|---|
| Boot loader | systemd-boot | Cleaner with UEFI + disko |
| Filesystem | btrfs subvolumes | Compression, snapshots, mature in NixOS |
| Root | tmpfs 4G | Impermanence — clean on every boot |
| Persist | btrfs subvol `@persist` mounted `/persist` | Whitelist via `environment.persistence` |
| Swap | zram (zstd, 50% RAM) | No disk swap, less wear |
| VPN | Tailscale | Best NixOS support, free tier, MagicDNS |
| Remote install | nixos-anywhere + kexec | No USB, in-place |
| Secrets | none yet | Wi-Fi PSK leaked via termbin → rotate post-fix |
| User auth | SSH ed25519 key only, no password | `users.mutableUsers = false`, `wheelNeedsPassword = false` |

## Disk layout (`hosts/lenoovo-pad/disko.nix`)

```
/dev/nvme0n1
├── p1 ESP 1G vfat → /boot
└── p2 100% btrfs
    ├── @nix     → /nix    (zstd, noatime)
    ├── @persist → /persist (zstd, noatime, neededForBoot)
    └── @log     → /var/log (zstd, noatime, neededForBoot)

/ = tmpfs 4G
```

## Persist whitelist (`environment.persistence."/persist"`)

Directories:
- `/var/lib/nixos`, `/var/lib/systemd`
- `/var/lib/tailscale` (auth state, node identity)
- `/var/lib/hass` (HA config DB)
- `/var/lib/containers` (podman)
- `/var/lib/NetworkManager`, `/etc/NetworkManager/system-connections`

Files:
- `/etc/machine-id`
- `/etc/ssh/ssh_host_{ed25519,rsa}_key{,.pub}`

## Files created/modified

| Path | Purpose |
|---|---|
| `flake.nix` | Added inputs: `disko`, `impermanence`, `nixos-images` |
| `configuration.nix` | Added `nix.settings.extra-sandbox-paths = [ "/dev/kvm" ]` (superthinker, for VM tests) |
| `hosts/lenoovo-pad/disko.nix` | New — btrfs subvol + tmpfs layout |
| `hosts/lenoovo-pad/hardware-configuration.nix` | Stripped fileSystems (disko owns) |
| `hosts/lenoovo-pad/configuration.nix` | Rewrite — headless, systemd-boot, impermanence, zram, key-only SSH |
| `modules/features/homelab.nix` | New — home-assistant + tailscale |
| `modules/hosts/lenoovo-pad.nix` | Wire disko, impermanence, homelab modules |
| `modules/hosts/kexec-wifi.nix` | New — custom kexec installer with Wi-Fi creds + firmware (one-time use, contains PSK — rotate) |

## Session timeline (what we hit)

1. **VM test setup** — `nixos-anywhere --vm-test` ran via TCG fallback (slow, ~35min stuck). Fixed: added `extra-sandbox-paths = /dev/kvm` to superthinker nix.conf, rebuilt, KVM acceleration enabled. VM test then passed fast.

2. **First real deploy** — kexec'd into default nixos-images installer. Post-kexec lost Wi-Fi (no PSK in installer). Powered laptop off, booted back to disk NixOS.

3. **Custom kexec installer v1** — built `nixosConfigurations.kexec-wifi` with `networking.wireless` baked in. Wrong output attr (`kexecTarball`) — only contained nix store, missing `kexec/run` script. nixos-anywhere extracted it over old `/root/kexec` but kept old `kexec/run` → installer used 25.05 default. Fixed: switched to `kexecInstallerTarball` (has `kexec/`).

4. **Custom kexec installer v2** — proper tarball. Kexec'd correctly. But iwlwifi probe failed: error `-110` (timeout). Two causes overlapping:
   - `netboot-minimal.nix` had `hardware.enableRedistributableFirmware = lib.mkOverride 70 false`. Our `= true` was priority 100 — lost. Fixed: `lib.mkForce true` + `nixpkgs.config.allowUnfree = true`.
   - PCI Wi-Fi card stuck post-kexec (known iwlwifi quirk — driver doesn't reset cleanly).
   
   `rmmod iwlmvm iwlwifi; modprobe iwlwifi` did not recover. Card stayed dead.

5. **Workaround: USB tether (Android Pixel 7)** — lenoovo-pad got internet via phone cellular. But Pixel 7 puts USB tether and Wi-Fi hotspot on different subnets — superthinker on hotspot couldn't reach lenoovo-pad on tether.

6. **Bootstrap via termbin** — tar'd flake repo (44KB, excluded wallpapers), base64'd, uploaded to `https://termbin.com/14n1`. User curled + extracted + ran `disko` + `nixos-install` directly on lenoovo-pad console. **Wi-Fi PSK was inside that tar — leaked publicly. Rotate "Mary Nade" PSK + scrub `kexec-wifi.nix` from history.**

7. **Install completed → reboot → no bootable devices found.**

## Next session: boot failure diagnosis

Possible causes of "no bootable devices":

1. **systemd-boot not installed to ESP**. `nixos-install` should auto-install but verify. ESP at `/dev/nvme0n1p1`, expected `/boot/EFI/systemd/systemd-bootx64.efi` + `/boot/EFI/BOOT/BOOTX64.EFI`.
2. **BIOS UEFI/Legacy mode mismatch**. IdeaPad S540 should be UEFI. Check Secure Boot disabled (systemd-boot doesn't support SB without lanzaboote).
3. **Boot order**. BIOS may not list NixOS — manually add boot entry or refresh.
4. **ESP not flagged ESP**. disko sets `EF00` GUID — should be fine.
5. **`boot.loader.efi.canTouchEfiVariables = true` but kexec'd installer can't write NVRAM**. NixOS would install bootloader files but BIOS doesn't know to boot them. Fix: BIOS → boot menu → add manual EFI entry pointing to `\EFI\systemd\systemd-bootx64.efi`, OR boot a live USB and run `efibootmgr -c -d /dev/nvme0n1 -p 1 -l '\EFI\systemd\systemd-bootx64.efi' -L NixOS`.

**Pragmatic next steps:**

1. Boot live USB (NixOS installer USB) on lenoovo-pad.
2. Mount partitions:
   ```
   mount -t btrfs -o subvol=@persist /dev/nvme0n1p2 /mnt/persist
   mount -t btrfs -o subvol=@nix /dev/nvme0n1p2 /mnt/nix
   mount /dev/nvme0n1p1 /mnt/boot
   ls /mnt/boot/EFI/  # check if systemd-boot present
   ```
3. If missing: `nixos-enter` into chroot, run `nixos-rebuild boot --flake .#lenoovo-pad`.
4. If present: fix BIOS via `efibootmgr` or BIOS UI boot manager.
5. Check BIOS Secure Boot status — disable if on.

**OR** consider GRUB instead of systemd-boot if BIOS issues persist — switch `boot.loader.systemd-boot.enable = false` + `boot.loader.grub.{enable=true; efiSupport=true; device="nodev";}`. GRUB more BIOS-quirk-tolerant.

## Open TODO post-boot-fix

- [ ] Rotate "Mary Nade" Wi-Fi password
- [ ] Remove `modules/hosts/kexec-wifi.nix` from repo (or sanitize PSK + git-filter-repo history)
- [ ] `sudo tailscale up` on lenoovo-pad, browser-auth, get MagicDNS name
- [ ] Browse to `http://lenoovo-pad:8123` for Home Assistant onboarding
- [ ] Add raspberry pi to tailnet later
- [ ] Consider agenix/sops-nix for future secrets
- [ ] Commit working state (currently dirty tree on superthinker)
- [ ] Decide whether to keep root SSH disabled (config already has `PermitRootLogin = "no"`)

## Reference: commands cheatsheet

Build kexec installer (when needed again):
```
nix build .#nixosConfigurations.kexec-wifi.config.system.build.kexecInstallerTarball
```

VM-test disko config:
```
nix run github:nix-community/nixos-anywhere -- --flake .#lenoovo-pad --vm-test
```

Full deploy via nixos-anywhere (when SSH reachable):
```
KEXEC=$(nix build --no-link --print-out-paths .#nixosConfigurations.kexec-wifi.config.system.build.kexecInstallerTarball)/nixos-kexec-installer-x86_64-linux.tar.gz
nix run github:nix-community/nixos-anywhere -- --flake .#lenoovo-pad --target-host root@<ip> --kexec "$KEXEC" -L
```

Self-install on target (from installer shell):
```
disko --mode destroy,format,mount --flake .#lenoovo-pad
nixos-install --root /mnt --flake .#lenoovo-pad --no-root-passwd
reboot
```
