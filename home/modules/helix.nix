{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    settings = {

      theme = "modus_vivendi_tritanopia";
      editor = {
        line-number = "relative";
      };

    };

    languages = {
      language-server.nixd = {
        command = "${pkgs.nixd}/bin/nixd";
        config.nixd = {
          nixpkgs.expr = "import <nixpkgs> {}";
          formatting.command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
        };
      };
      language = [
        {
          name = "nix";
          auto-format = true;
          language-servers = [ "nixd" ];
        }
      ];
    };

  };
}
