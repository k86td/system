{ pkgs, ...}:
{
  wallpapers = {

    darkeye = {
      img = pkgs.stdenv.mkDerivation rec {
        name = "darkeye";
        src = ./;
        dontUnpack = true;
        installPhase = ''
          mkdir -p $out
          cp ${src}/darkeye.jpg $out
        '';
      };
      colors = {
        background = "#181C14";
        tertiary = "#3C3D37";
        secondary = "#697565";
        primary = "#ECDFCC";
      };
    };

    grayabstract = {
      img = pkgs.stdenv.mkDerivation rec {
        name = "grayabstract";
        src = ./;
        dontUnpack = true;
        installPhase = ''
          mkdir -p $out
          cp ${src}/gray-abstract.png $out
        '';
      };
    };

  };
}
