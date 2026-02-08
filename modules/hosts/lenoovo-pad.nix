{ inputs, ... }: {
  flake.nixosConfigurations.lenoovo-pad = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ../../hosts/lenoovo-pad/configuration.nix
      inputs.determinate.nixosModules.default
    ];
  };
}
