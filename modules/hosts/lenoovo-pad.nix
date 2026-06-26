{ inputs, ... }:
{
  flake.nixosConfigurations.lenoovo-pad = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ../../hosts/lenoovo-pad/configuration.nix
      inputs.determinate.nixosModules.default
      inputs.disko.nixosModules.disko
      inputs.impermanence.nixosModules.impermanence
      inputs.self.nixosModules.caches
      inputs.self.nixosModules.containers
      inputs.self.nixosModules.homelab
    ];
  };
}
