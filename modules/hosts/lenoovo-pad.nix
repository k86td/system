{ inputs, ... }: {
  flake.nixosConfigurations.lenoovo-pad = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ../../hosts/lenoovo-pad/configuration.nix
      inputs.determinate.nixosModules.default
      inputs.self.nixosModules.openclaw
      inputs.self.nixosModules.caches

      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.tlepine = {
          imports = [
            ../../home/new-tlepine.nix
            inputs.zen-browser.homeModules.beta
          ];
        };
      }
    ];
  };
}
