{ lib
, stdenv
, autoPatchelfHook
, makeWrapper
, unzip
, gtk3
, webkitgtk_4_1
, libsecret
, libXtst
, ncurses5
, qt6
, alsa-lib
, libxkbcommon
, libXxf86vm
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
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    gtk3
    webkitgtk_4_1
    libsecret
    libXtst
    ncurses5
    qt6.qtwayland
    alsa-lib
    libxkbcommon
    libXxf86vm
    stdenv.cc.cc.lib  # libstdc++
  ];

  # Ignore missing optional libraries (mostly ffmpeg plugins that aren't critical)
  autoPatchelfIgnoreMissingDeps = [
    "libavcodec.so.54"
    "libavcodec.so.56"
    "libavcodec.so.57"
    "libavcodec.so.58"
    "libavcodec.so.59"
    "libavcodec.so.60"
    "libavformat.so.54"
    "libavformat.so.56"
    "libavformat.so.57"
    "libavformat.so.58"
    "libavformat.so.59"
    "libavformat.so.60"
    "libavcodec-ffmpeg.so.56"
    "libavformat-ffmpeg.so.56"
    "libpcsclite.so.1"        # Smart card support (optional)
    "libxerces-c-3.2.so"      # XML library (optional)
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

    # Extract the main tar.gz directly (skip interactive installer)
    cd extract
    tar xzf st-stm32cubeide_*.tar.gz

    echo "=== After tar extraction ==="
    ls -la

    # Find the extracted directory
    extracted_dir=$(find . -maxdepth 1 -type d -name "stm32cubeide*" | head -1)
    echo "Found directory: $extracted_dir"

    # Install to $out/libexec (we'll create a wrapper)
    mkdir -p $out/libexec/stm32cubeide
    if [ -d "$extracted_dir" ]; then
      cp -r "$extracted_dir"/* $out/libexec/stm32cubeide/
    else
      echo "No stm32cubeide directory found, copying everything"
      cp -r . $out/libexec/stm32cubeide/
    fi

    # Make the main binary executable
    chmod +x $out/libexec/stm32cubeide/stm32cubeide

    # Create wrapper script
    mkdir -p $out/bin
    makeWrapper $out/libexec/stm32cubeide/stm32cubeide $out/bin/stm32cubeide \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --set WEBKIT_DISABLE_DMABUF_RENDERER 1

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
