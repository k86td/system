{ inputs, pkgs, ... }: {
  flake.nixosModules.openclaw = { config, lib, pkgs, ... }: {
    config = {
      nixpkgs.overlays = [ inputs.nix-openclaw.overlays.default ];

      users.users.openclaw = {
        isNormalUser = true;
        description = "OpenClaw Agent";
        extraGroups = [ "wheel" "networkmanager" ]; # Add groups as needed
        packages = with pkgs; [ gemini-cli home-manager ];

        # We allow passwordless sudo for convenience if needed, or just standard user
      };
      
      # Allow openclaw user to be managed by home-manager
      nix.settings.trusted-users = [ "openclaw" ];
    };
  };
}
