{ lib, stdenv }:

stdenv.mkDerivation {
  pname = "test-tiempos-fonts";
  version = "1.0";
  
  src = ./files;
  
  installPhase = ''
    mkdir -p $out/share/fonts/opentype/test-tiempos
    cp *.otf $out/share/fonts/opentype/test-tiempos/
  '';
  
  meta = with lib; {
    description = "Test Tiempos font family - Fine, Headline, and Text variants";
    license = licenses.unfree; # Free for personal use
    platforms = platforms.all;
  };
}