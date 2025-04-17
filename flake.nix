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
    hyprland = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1&tag=v0.45.1";
    };
  };

  outputs = { self, nixpkgs, lanzaboote, nixos-hardware, home-manager, ...}@attrs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    cfg = {
      repoDecrypted = builtins.hashFile "sha256" ./secrets/state == builtins.hashString "sha256" "decrypted\n";
    };
  in
  {
    nixosConfigurations = {
      superthinker = nixpkgs.lib.nixosSystem {
        # this sends down to the imported modules the variables inherited
        specialArgs = {
          inherit cfg;
        };
        modules = [
          ./configuration.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-t490
        ];
      };

      lenoovo-pad = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/lenoovo-pad/configuration.nix
        ];
      };
    };

    homeConfigurations."ebox-tlepine" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./home/ebox-tlepine.nix
      ];
    };

    homeConfigurations."new-tlepine" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./home/new-tlepine.nix
      ];
    };

  };
}
