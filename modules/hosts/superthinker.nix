{ inputs, withSystem, ... }: {
  flake.nixosConfigurations.superthinker = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ../../configuration.nix
      inputs.self.nixosModules.mdns
    ];
  };

  # flake.homeConfigurations.tlepine = withSystem "x86_64-linux" ({ pkgs, system, ... }:
  #   inputs.home-manager.lib.homeManagerConfiguration {
  #     inherit pkgs;
  #     modules = [
  #       ../../home/new-tlepine.nix
  #       inputs.zen-browser.homeModules.beta
  #       {
  #         home.packages = [
  #           inputs.claude-desktop.packages.${system}.claude-desktop-with-fhs
  #         ];
  #       }
  #     ];
  #   }
  # );
}
