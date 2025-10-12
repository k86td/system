{ lib
, stdenv
, autoPatchelfHook
, makeWrapper
, unzip
, gtk3
, webkitgtk
, libsecret
, libXtst
}:

stdenv.mkDerivation rec {
  pname = "stm32cubeide";
  version = "1.19.0";

  # For testing with local file, replace with requireFile for final version
  src = /nix/store/bk7l6hhdv80lla23rpp2cgk3gdpmdp66-st-stm32cubeide_1.19.0_25607_20250703_0907_amd64.sh.zip;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    unzip
  ];

  buildInputs = [
    gtk3
    webkitgtk
    libsecret
    libXtst
  ];

  unpackPhase = ''
    runHook preUnpack
    unzip $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    # Extract the shell bundle
    chmod +x *.sh
    bash ./st-stm32cubeide_*.sh --noexec --target extract

    mkdir -p $out
    ls -la
    ls -la extract/

    runHook postInstall
  '';

  meta = with lib; {
    description = "STM32CubeIDE - STM32 microcontroller development tool";
    homepage = "https://www.st.com/en/development-tools/stm32cubeide.html";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
