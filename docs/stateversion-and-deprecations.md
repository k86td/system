# `stateVersion` review + deprecation audit

Date: 2026-08-20. Audited against `nixos-unstable` @ `ffb3c9b` (26.11pre1058091, 2026-08-19)
and `home-manager` master @ `c53d643`, i.e. what a `nix flake update` would pull today.

Every claim below was verified by evaluating this flake, not by reading docs alone.
Method: all `github:` inputs rewritten to `git+https://` at the same revs (tarball fetches
were blocked in the audit sandbox), `nixpkgs` swapped for the current channel tarball.

---

## TL;DR

| Question | Answer |
| --- | --- |
| Does `system.stateVersion` need bumping? | **No. Leave it at `24.11`.** Proven no-op — see below. |
| Does bumping it change anything at all? | **Nothing.** Byte-identical system derivations for 24.11 / 25.05 / 25.11 / 26.05. |
| Does `home.stateVersion` matter? | **Yes** — and it is already at `26.05` for both live users, so that migration is done. |
| What actually breaks on `nix flake update`? | Both hard failures (openclaw, logseq) have since been removed from the repo; 4 deprecation warnings remain. See §3. |

---

## 1. `system.stateVersion` — do not bump

### 1.1 The empirical test

Each host was evaluated four times, forcing `system.stateVersion` to each candidate value:

```
superthinker   24.11  /nix/store/1fa3252zxnc1vy254ilvvw36k65y99ci-nixos-system-superthinker-...drv
superthinker   25.05  /nix/store/1fa3252zxnc1vy254ilvvw36k65y99ci-nixos-system-superthinker-...drv
superthinker   25.11  /nix/store/1fa3252zxnc1vy254ilvvw36k65y99ci-nixos-system-superthinker-...drv
superthinker   26.05  /nix/store/1fa3252zxnc1vy254ilvvw36k65y99ci-nixos-system-superthinker-...drv

lenoovo-pad    24.11  /nix/store/h8a0sgr0dv9g2x9j2v0ps2hjp2fr1lkm-nixos-system-lenoovo-pad-...drv
lenoovo-pad    25.05  /nix/store/h8a0sgr0dv9g2x9j2v0ps2hjp2fr1lkm-nixos-system-lenoovo-pad-...drv
lenoovo-pad    25.11  /nix/store/h8a0sgr0dv9g2x9j2v0ps2hjp2fr1lkm-nixos-system-lenoovo-pad-...drv
lenoovo-pad    26.05  /nix/store/h8a0sgr0dv9g2x9j2v0ps2hjp2fr1lkm-nixos-system-lenoovo-pad-...drv
```

Identical derivation paths ⇒ identical closures. Bumping `system.stateVersion` on these two
hosts is a **literal no-op**. There is nothing to migrate, and nothing to gain.

### 1.2 Why

`system.stateVersion` only feeds modules that manage on-disk state whose format can't be
auto-migrated. The complete set of `stateVersion`-gated modules in current nixpkgs is:

`postgresql`, `mysql`, `nextcloud`, `mattermost`, `stalwart`, `dovecot`, `netbox`, `sabnzbd`,
`transmission`, `deluge`, `taskchampion-sync-server`, `tandoor-recipes`, `zfs`, `nebula`,
`unifi`, `vaultwarden`, `syncthing`, `kubo`, `graylog`, `odoo`, `akkoma`, `synapse`,
`invidious`, `hedgedoc`, `pict-rs`, `radicale`, `ntopng`, `supybot`, `zabbix`, `gitlab`,
`lauti`, `olivetin`, `nftables`, `swraid`, `xterm`, `gnome-initial-setup`.

**None of them are enabled on either host.** The media stack (`jellyfin`, `radarr`, `sonarr`,
`prowlarr`, `qbittorrent`, `flaresolverr`), `home-assistant`, `tailscale`, `avahi`, `greetd`,
`niri`, `steam`, `docker`/`podman`, `waydroid` — none consult `stateVersion`.

### 1.3 What upstream says

From `nixos/modules/misc/version.nix` (current unstable):

> Most users should **never** change this value after the initial install, for any reason,
> even if you've upgraded your system to a new NixOS release.
>
> This value does **not** affect the Nixpkgs version your packages and OS are pulled from,
> so changing it will **not** upgrade your system.
>
> This value being lower than the current NixOS release does **not** mean your system is
> out of date, out of support, or vulnerable.

### 1.4 Verdict

Keep `system.stateVersion = "24.11"` in `configuration.nix:296` and
`hosts/lenoovo-pad/configuration.nix:142`. The only thing worth changing is the comment —
replace the boilerplate `# Did you read the comment?` with a note saying it's deliberate.

**The one future caveat:** if you ever enable PostgreSQL, Nextcloud, or Transmission on these
hosts, `stateVersion = 24.11` picks *old* defaults (e.g. PostgreSQL 16 rather than 18,
Nextcloud 31 rather than 34). That's the correct behaviour for an existing machine, but for a
brand-new service you'd want to pin the version explicitly instead of raising `stateVersion`.

### 1.5 `kexec-wifi` is different

`modules/hosts/kexec-wifi.nix` sets no `stateVersion`, so it defaults to the nixpkgs release
(currently `26.11`) and emits the "system.stateVersion is not set, defaulting to …" warning on
every build. For a throwaway kexec installer image that is harmless and arguably correct —
it holds no persistent state. Optional: set it explicitly to silence the warning.

---

## 2. `home.stateVersion` — this one *does* change things (already done)

Unlike the NixOS side, the Home Manager activation derivation genuinely differs per version:

```
24.11  h23yp9i61ym4b39rynhs277applpbmyv-home-manager-generation.drv
25.05  hqfsvx644lmssx8c26nr9dy1nd1c5rbp-home-manager-generation.drv   (differs)
25.11  hqfsvx644lmssx8c26nr9dy1nd1c5rbp-home-manager-generation.drv
26.05  nyy8313sdqxh1pxdq1p8k8y5j1a7yv81-home-manager-generation.drv   (differs)
```

Diffing the generated files for `tlepine` between 24.11 and 26.05:

- **`~/.config/git/config`** — at `< 25.05` HM injects `gpg.format = openpgp` and
  `gpg.openpgp.program = …gnupg/bin/gpg`; at `>= 25.05` those defaults are gone
  (and gnupg leaves the closure).
- **`~/.config/nvim/init.lua`** — at `< 26.05` the Ruby and Python3 Neovim providers are wired
  up (`neovim-ruby-env`, `nvim-host-python3-3.14.7-env` in the closure); at `>= 26.05` they are
  `loaded_ruby_provider = 0` / `loaded_python3_provider = 0`.
- **Firefox profile path** — at `< 26.05` `programs.firefox.configPath` is `.mozilla/firefox`;
  at `>= 26.05` it becomes `${xdg.configHome}/mozilla/firefox` (i.e. `~/.config/mozilla/firefox`).

`home/new-tlepine.nix:370` and `home/ebox-tlepine.nix:40` already declare `26.05`, and the
currently-pinned home-manager (`61e2c96`, 2026-05-28) already contains all three gates —
so these changes are **already live on your machine**, not pending. Nothing to do.

The full set of HM `stateVersion` gates that could still bite you later:

| Module | Since | Effect |
| --- | --- | --- |
| `programs.git` | 25.05 | gpg signing defaults dropped |
| `programs.firefox` | 26.05 | profile path moves to `~/.config/mozilla/firefox` |
| `programs.neovim` | 26.05 | ruby/python3 providers off by default |
| `programs.zsh`, `programs.man`, `services.colima`, `programs.docker-cli` | 26.05 | XDG-ify dotfiles **when `xdg.enable = true`** (it is not, here) |
| `programs.yazi`, `misc/gtk4`, `xdg.userDirs`, `hyprland` | 26.05 | default changes |
| `misc/fontconfig` | **26.11** | upcoming — will apply if you ever raise to 26.11 |

### 2.1 Consistency

The audit originally found `modules/users/openclaw.nix` sitting at `home.stateVersion =
"24.11"` while the other two home configs were at `26.05`. That file has since been removed
(§3.1), so both remaining home configs — `home/new-tlepine.nix` and the orphaned
`home/ebox-tlepine.nix` — now agree on `26.05`.

---

## 3. What actually breaks on `nix flake update`

Current state was verified first: **all three `nixosConfigurations` evaluate cleanly against
today's unstable, with zero `config.warnings` on every host.** No renamed or removed NixOS
option is in use anywhere in the repo. The problems are all package-level or home-level.

### 3.1 Hard failures — resolved by removal (2026-08-20)

Two configurations failed outright against current upstream. Both have since been deleted
from the repo, since neither was in use. Recorded here for the history.

**(a) `homeConfigurations.openclaw` — `programs.openclaw.documents` was removed**

`modules/users/openclaw.nix` set `programs.openclaw.documents`. At the pinned `nix-openclaw`
rev (`773708b`) that option worked; at upstream HEAD it is a stub that fires a hard assertion
directing you to `programs.openclaw.workspace.bootstrapFiles` / `workspace.files`.

**Resolved:** `modules/users/openclaw.nix`, `modules/features/openclaw.nix` and the
`nix-openclaw` flake input were removed. If OpenClaw comes back, it needs the
`workspace.*` API, not `documents`.

**(b) `homeConfigurations.tlepine` — `logseq` is marked insecure**

```
error: Refusing to evaluate package 'electron-39.8.10' … because it is marked as insecure
Known issues: Electron version 39.8.10 is EOL
```

**Resolved:** `logseq` was dropped from `home/new-tlepine.nix`. If it comes back it will need
`nixpkgs.config.permittedInsecurePackages = [ "electron-39.8.10" ]`, re-pinned on every
electron bump — or an upstream electron bump in the `logseq` derivation.

**Current status:** with those two gone, all four flake outputs (`superthinker`,
`lenoovo-pad`, `kexec-wifi`, `homeConfigurations.tlepine`) evaluate cleanly against
`nixos-unstable` @ `ffb3c9b` and home-manager master, with no `NIXPKGS_ALLOW_INSECURE` and
no assertion failures. Only the §3.2 warnings remain.

### 3.2 Deprecation warnings (build succeeds, fix at leisure)

| # | Where | Warning | Fix |
| --- | --- | --- | --- |
| 1 | `configuration.nix:191,208,212,213,214` | `The xorg package set has been deprecated` | `xorg.xinit`→`xinit`, `xorg.libXxf86vm`→`libxxf86vm`, `xorg.libXtst`→`libxtst`, `xorg.xwininfo`→`xwininfo`, `xorg.xprop`→`xprop` |
| 2 | `home/modules/herdr.nix:4` | `'system' has been renamed to/replaced by 'stdenv.hostPlatform.system'` | `inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default` |
| 3 | `home/new-tlepine.nix:345` | `Relying on 'home.pointerCursor' to enable cursor config generation is deprecated` | add `enable = true;` inside the block |
| 4 | `home/new-tlepine.nix` (`gemini-cli`) | `gemini-cli … has the following problem: removal` — replaced upstream by Antigravity CLI | switch to `antigravity-cli` (present in nixpkgs, 1.1.13) or drop it |

The `xorg` alias set was added 2026-01-29 and currently only warns; nixpkgs converts such
aliases to hard `throw`s after roughly a year, so item 1 has a deadline of about 2027-01.

---

## 4. Release-note items relevant to these hosts (25.05 → 26.11)

Already handled — no action needed:

- **25.11** NetworkManager no longer ships default VPN plugins; they must be listed in
  `networking.networkmanager.plugins`. Already done (`configuration.nix`, `networkmanager-openvpn`).
- **25.11** `virtualisation.waydroid.package` defaults to `waydroid-nftables`. Already set explicitly.
- **25.05** `system.stateVersion` is now format-validated (`YY.MM`). Both hosts comply.
- **26.05** `services.avahi.wideArea` now defaults to `false` (CVE-2024-52615). Not relied on here.

Watch items for the next update (your `nixpkgs` follows unstable, i.e. 26.11pre):

- **26.11** Avahi's mDNS NSS module now enables only the *minimal* resolver by default. `.local`
  lookups keep working; if you ever need mDNS for non-`.local` domains you must set
  `services.avahi.nssmdnsFull = true`. Relevant given the `lenoovo-pad.local` resolution issue
  in the README's to-do list.
- **26.11** `security.polkit.enablePkexecWrapper` is now opt-in. `configuration.nix` enables
  polkit; if anything you use shells out to `pkexec`, enable the wrapper explicitly.
- **26.11** systemd-boot loader entries are renamed to `nixos-<content-hash>.conf` and migrated
  automatically on the next `nixos-rebuild boot`/`switch`. `lenoovo-pad` uses systemd-boot —
  expect a one-time ESP rewrite. (`superthinker` is on GRUB; unaffected.)
- **25.05** subuid ranges were reallocated for multi-user systems; with rootless podman this
  can require `chown` of affected files. Both hosts run podman.
- **Impermanence + DynamicUser drift.** `hosts/lenoovo-pad/configuration.nix:74` persists
  `/var/lib/private/prowlarr`. Upstream keeps migrating services off `DynamicUser` (esphome did
  in 26.05), which moves state from `/var/lib/private/X` to `/var/lib/X`. If prowlarr ever
  follows, that persistence entry goes stale **silently** and you lose the config on reboot.
  Worth a periodic check.

---

## 5. Unrelated issues found during the audit

These aren't `stateVersion` matters, but they're real and cheap to fix:

1. **`pkgs/default.nix` is dead code.** The overlay is never referenced — nothing imports
   `./pkgs`, and no `nixpkgs.overlays` entry points at it. So the deliberate stable pinning of
   `intel-graphics-compiler` / `intel-compute-runtime` ("avoid CMake 4.0 build issues") is
   **not in effect**, and neither is the `vimPlugins` merge. Either wire it up or delete it —
   right now the comment describes something the build isn't doing.
2. **`pkgs/vimPlugins/claudecode-nvim` is redundant.** nixpkgs ships
   `vimPlugins.claudecode-nvim` (0.3.0-unstable-2026-06-25); the local derivation pins v0.1.0.
   Because the overlay is dead (see 1), `home/modules/neovim/default.nix:27` is already
   resolving to the *upstream* plugin. Delete the local copy.
3. ~~**Home Manager aliases point at output names that don't exist.**~~ Fixed 2026-08-20 by
   deleting both broken aliases (`hw` in `home/new-tlepine.nix`, `sw` in
   `home/ebox-tlepine.nix`) — they pointed at `#new-tlepine` / `#ebox-tlepine`, but the only
   home output is `tlepine`. Re-add as `home-manager switch --flake /etc/nixos#tlepine` if
   you want the shortcut back.
4. **`home/ebox-tlepine.nix` is orphaned and would not evaluate.** No flake output references
   it, and it uses `cfg.repoDecrypted` plus `import ../secrets/govc.nix` — `secrets/` does not
   exist in the repo. Wire it up with the missing pieces, or delete it.
5. **`home/new-tlepine.nix:3` takes a `cfg` module argument that is never provided.** It works
   only because the module system binds unknown args to a lazy `throw`, and nothing in that
   file reads `cfg`. It is a landmine — remove the argument.
6. **`home/modules/shells.nix` is an empty module** that binds `config.myself.shells`, an
   option that is never declared. Same lazy-throw situation. Delete it or finish it.

---

## 6. The plan

**Step 0 — decision.** Do not touch `system.stateVersion`. Optionally reword the comment:

```nix
# Deliberately pinned to the original install release. Verified 2026-08-20: no module in
# use on this host reads system.stateVersion, so raising it is a no-op. See
# docs/stateversion-and-deprecations.md
system.stateVersion = "24.11";
```

**Step 1 — clear the update blockers.** Done 2026-08-20: OpenClaw and `logseq` removed
(§3.1). Nothing else blocks an update.

**Step 2 — `nix flake update`, then evaluate every output before switching:**

```bash
nix flake update
for h in superthinker lenoovo-pad kexec-wifi; do
  nix eval .#nixosConfigurations.$h.config.system.build.toplevel.drvPath
done
nix eval .#homeConfigurations.tlepine.activationPackage.drvPath
```

**Step 3 — clear the four deprecation warnings** (§3.2). All are mechanical one-liners.

**Step 4 — switch,** `lenoovo-pad` first (it's the recoverable one; expect the systemd-boot
entry rename), then `superthinker`.

**Step 5 — hygiene pass** (§5), separately from the update so a regression is easy to bisect.

---

## Appendix — how this was verified

- Nix 2.35.2, single-user install; every flake output evaluated (five before the OpenClaw
  removal, four after).
- `stateVersion` sensitivity measured with `nixosConfigurations.<host>.extendModules` forcing
  each candidate value and comparing `system.build.toplevel.drvPath`.
- Home Manager differences measured the same way, then narrowed by diffing
  `config.home.file.<path>.source` and the resulting `writeText` payloads.
- `config.warnings` evaluated explicitly per host (empty on all three).
- The `nix-openclaw` regression confirmed by diffing
  `nix/modules/home-manager/openclaw/options.nix` between the pinned rev and upstream HEAD.
- All 13 pinned input revisions in `flake.lock` confirmed still fetchable from their upstreams.
