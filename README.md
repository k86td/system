# NixOS Configuration (Dendritic Pattern)

This repository manages my NixOS systems and home environments using a **Dendritic** (tree-like) modular structure powered by [flake-parts](https://github.com/hercules-ci/flake-parts) and [import-tree](https://github.com/vic/import-tree).

## 🌳 The Dendritic Pattern

Unlike traditional Nix configurations that require manual tracking of `imports = [ ... ]`, this repository uses `import-tree` to automatically traverse the `modules/` directory.

Adding a new file anywhere in `modules/` automatically integrates its logic into the flake outputs. This creates a self-organizing structure where features, hosts, and users are discovered by the tree walker.

## 📂 Repository Structure

### ❄️ Entry Point (`flake.nix`)
The core orchestrator. It defines inputs and uses `flake-parts` to merge configuration fragments gathered by `import-tree ./modules`.

### 🧱 Shared Base (`configuration.nix`, `hardware-configuration.nix`)
Top-level `configuration.nix` is the shared NixOS base imported by host modules (see `modules/hosts/superthinker.nix`). `hardware-configuration.nix` is the generated hardware module used by hosts that share this machine's profile.

### ⚙️ The Tree (`modules/`)
This directory is the core of the flake. Every file here is auto-imported.
- **`flake-parts.nix`**: Wires `home-manager.flakeModules.default` and declares `systems = [ "x86_64-linux" ]`.
- **`hosts/`**: Defines `nixosConfigurations` (e.g., `lenoovo-pad`, `superthinker`).
- **`users/`**: Defines `homeConfigurations` (e.g., `tlepine`, `openclaw`).
- **`features/`**: Reusable NixOS modules exposed via `flake.nixosModules`.
  - `caches.nix`: Binary cache settings.
  - `openclaw.nix`: OpenClaw agent and user configuration.
  - `mdns.nix`: Multicast DNS setup.
  - `mediaserver.nix`: Media services configuration.
- **`developmentShell.nix`**: Defines the `nix develop` environment.

### 🖥️ Machine Configs (`hosts/`)
Per-host directories holding machine-specific NixOS code and hardware definitions. Not every host needs an entry here — hosts that fully reuse the top-level `configuration.nix` (e.g. `superthinker`) only have a `modules/hosts/<name>.nix` definition.
- **`lenoovo-pad/`**: Configuration and hardware definitions for the Lenovo Pad.

### 🏠 Home Environments (`home/`)
User-centric configuration managed by Home Manager.
- **`modules/`**: Modular HM components (Neovim, Helix, Nushell, etc.).
- **`files/`**: Static configuration files (dotfiles) managed via `home.file`.
- **`new-tlepine.nix`, `ebox-tlepine.nix`**: User profile definitions.

### 📦 Packages & Overlays (`pkgs/`)
- **`default.nix`**: The primary overlay. Bridges specific stable/unstable versions and merges custom plugin sets.
- **`vimPlugins/`**: Custom Vim/Neovim plugin derivations (e.g. `claudecode-nvim`).

## 🛠️ Dendritic Workflow

### Adding a New Host
1. Create `hosts/new-host/configuration.nix`.
2. Create `modules/hosts/new-host.nix` to define the flake output:
   ```nix
   { inputs, ... }: {
     flake.nixosConfigurations.new-host = inputs.nixpkgs.lib.nixosSystem {
       system = "x86_64-linux";
       modules = [
         ../../configuration.nix
         ../../hosts/new-host/configuration.nix
         inputs.self.nixosModules.mdns
       ];
     };
   }
   ```
   Reuse shared modules via `inputs.self.nixosModules.<feature>` (matches `modules/hosts/superthinker.nix`).

### Adding a Shared Feature
1. Create `modules/features/my-feature.nix`.
2. Define the module under `flake.nixosModules.my-feature`.
3. It is now automatically available to all hosts via `inputs.self.nixosModules.my-feature`.

## 🚀 Usage

### Development Shell
```bash
nix develop
```

### Applying Configuration
```bash
sudo nixos-rebuild switch --flake .#<hostname>
home-manager switch --flake .#<username>
```
