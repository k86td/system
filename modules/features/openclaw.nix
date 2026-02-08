{ inputs, ... }: {
  flake.nixosModules.openclaw = { config, lib, pkgs, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    config = {
      nixpkgs.overlays = [ inputs.nix-openclaw.overlays.default ];

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.tlepine = {
        imports = [ inputs.nix-openclaw.homeManagerModules.openclaw ];

        programs.openclaw = {
          enable = true;
          documents = pkgs.runCommand "openclaw-documents" { } ''
            mkdir -p $out
            cat <<EOF > $out/AGENTS.md
            # Agents
            Define your agents here.
            EOF
            cat <<EOF > $out/SOUL.md
            # Soul
            Define your agent's soul/personality here.
            EOF
            cat <<EOF > $out/TOOLS.md
            # Tools
            Define available tools here.
            EOF
          '';

          config = {
            gateway = {
              mode = "local";
              # We'll generate a random token for local gateway auth
              auth.token = "local-dev-token-change-me-if-exposed"; 
            };

            channels.discord = {
              tokenFile = config.users.users.tlepine.home + "/.secrets/discord_token";
              allowFrom = [ "353705706316365835" ];
            };
          };

          instances.default = {
            enable = true;
            plugins = [
              # Add plugins here
            ];
          };
        };

        home.file."Documents/openclaw".source = config.home-manager.users.tlepine.programs.openclaw.documents;
      };
    };
  };
}
