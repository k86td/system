{
  description = "System Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, ...}@attrs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        (final: prev: import ./pkgs prev)
      ];
    };

    cfg = {
      repoDecrypted = builtins.hashFile "sha256" ./secrets/state == builtins.hashString "sha256" "decrypted\n";
      wallpapers = (import ./home/files/wallpapers/default.nix { inherit pkgs; });
    };
  in
  {
    nixosConfigurations = {
      superthinker = nixpkgs.lib.nixosSystem {
        inherit system;
        # this sends down to the imported modules the variables inherited
        specialArgs = {
          inherit cfg;
        };
        modules = [
          {
            nixpkgs.overlays = [
              (import ./pkgs)
            ];
          }
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
      
      extraSpecialArgs = {
        inherit cfg;
      };
      
      modules = [
        ./home/ebox-tlepine.nix
      ];
    };

    homeConfigurations."new-tlepine" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      extraSpecialArgs = {
        inherit cfg;
      };

      modules = [
        ./home/new-tlepine.nix
      ];
    };

  };
}
