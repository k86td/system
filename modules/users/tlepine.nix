{ inputs, withSystem, ... }: {
  flake.homeConfigurations.tlepine = withSystem "x86_64-linux"
    ({ pkgs, system, ... }:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ../../home/new-tlepine.nix
          ../../home/modules/neovim
          ../../home/modules/helix.nix
          inputs.zen-browser.homeModules.beta
        ];
      });
}
