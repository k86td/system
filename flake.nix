{
  description = "System Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1&tag=v0.43.0";
  };

  outputs = { self, nixpkgs, lanzaboote, nixos-hardware, home-manager, ...}@attrs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    nixosConfigurations = {
      superthinker = nixpkgs.lib.nixosSystem {
        # TODO: wtf is this?
        specialArgs = attrs;
        modules = [
          lanzaboote.nixosModules.lanzaboote
          ./configuration.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-t490
          home-manager.nixosModules.home-manager {
            home-manager.users.tlepine = import ./home/tlepine.nix;
          }
        ];
      };
    };

    homeConfigurations."ebox-tlepine" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./home/ebox-tlepine.nix
      ];
    };

  };
}
