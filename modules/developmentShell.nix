{ ... }: {
  perSystem = { pkgs, ... }: {
    # On définit le shell par défaut pour ce système
    devShells.default = pkgs.mkShell {
      name = "nixos-dev-shell";

      # Les outils disponibles dans le shell
      packages = with pkgs; [
        nixd # Le LSP pour Nix
        alejandra # Le formateur de code
      ];

      # Optionnel : variables d'environnement ou scripts de bienvenue
      shellHook = ''
        echo "❄️ Environnement de développement Nix chargé avec nixd et alejandra."
      '';
    };
  };
}
