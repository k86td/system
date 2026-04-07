{ inputs, withSystem, ... }: {
  flake.nixosConfigurations.superthinker = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ../../configuration.nix
      inputs.self.nixosModules.mdns
    ];
  };
}
