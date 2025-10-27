{
  description = "System Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gaul-tooling = {
      url = "github:k86td/gaul-tooling";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, nixos-hardware, home-manager, ...}@attrs:
  let
    system = "x86_64-linux";
    pkgs-stable = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        (import ./pkgs { inherit pkgs-stable; })
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
              (import ./pkgs { inherit pkgs-stable; })
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
        inputs = attrs;
      };

      modules = [
        attrs.gaul-tooling.homeModules.default
        ./home/new-tlepine.nix
        {
          nixpkgs.config.allowUnfree = true;
          gaul.enable = true;
        }
      ];
    };

    packages.${system} = {
      inherit (pkgs) stm32cubeide;
    };

  };
}
