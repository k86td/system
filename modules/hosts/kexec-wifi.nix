{ inputs, ... }: {
  flake.nixosConfigurations.kexec-wifi = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-images.nixosModules.kexec-installer
      inputs.nixos-images.nixosModules.noninteractive
      ({ pkgs, lib, ... }: {
        hardware.enableRedistributableFirmware = lib.mkForce true;
        nixpkgs.config.allowUnfree = true;

        networking.wireless = {
          enable = true;
          interfaces = [ "wlp0s20f3" ];
          networks."Mary Nade".psk = "uD98AwPQpR";
        };

        environment.systemPackages = with pkgs; [
          iw
          wpa_supplicant
          wirelesstools
        ];

      })
    ];
  };
}
