{ inputs, ... }: {
  flake.nixosConfigurations.lenoovo-pad = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.self.nixosModules.caches
      ../../hosts/lenoovo-pad/configuration.nix
      inputs.determinate.nixosModules.default
      inputs.self.nixosModules.openclaw
    ];
  };
}
