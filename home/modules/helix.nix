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
      language-server.qmlls = {
        command = "${pkgs.qt6.qtdeclarative}/bin/qmlls";
        args = [
          "-E"
          "-I" "${pkgs.quickshell}/lib/qt-6/qml"
          "-I" "${pkgs.qt6.qtdeclarative}/lib/qt-6/qml"
        ];
      };
      language = [
        {
          name = "nix";
          auto-format = true;
          language-servers = [ "nixd" ];
        }
        {
          name = "qml";
          language-servers = [ "qmlls" ];
        }
      ];
    };

  };
}
