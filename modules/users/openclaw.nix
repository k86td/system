{ inputs, withSystem, ... }: builtins.trace "Evaluating openclaw.nix" {
  flake.homeConfigurations.openclaw = withSystem "x86_64-linux" ({ system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.nix-openclaw.overlays.default ];
        config.allowUnfree = true; # OpenClaw might need unfree packages
      };
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        inputs.nix-openclaw.homeManagerModules.openclaw
        ({ config, ... }: {
          home.username = "openclaw";
          home.homeDirectory = "/home/openclaw";
          home.stateVersion = "24.11";
          programs.home-manager.enable = true;

          # OpenClaw Configuration
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
                auth.token = "local-dev-token-change-me-if-exposed"; 
              };

              channels.discord = {
                tokenFile = config.home.homeDirectory + "/.secrets/discord_token";
                allowFrom = [ "353705706316365835" ];
              };
            };

            instances.default = {
              enable = true;
              plugins = [];
            };
          };

          home.file."documents".source = config.programs.openclaw.documents;
        })
      ];
    }
  );
}
