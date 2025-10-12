{ lib
, buildFHSUserEnv
, stm32cubeide-unwrapped
}:

buildFHSUserEnv {
  name = "stm32cubeide";

  targetPkgs = pkgs: (with pkgs; [
    stm32cubeide-unwrapped
    gtk3
    webkitgtk_4_1
    libsecret
    libXtst
    ncurses5
    qt6.qtwayland
    alsa-lib
    libxkbcommon
    libXxf86vm
    zlib
    glib
    xorg.libX11
    xorg.libXrender
    xorg.libXext
    fontconfig
    freetype
    pango
    cairo
    gdk-pixbuf
    atk
  ]);

  runScript = "stm32cubeide";

  meta = stm32cubeide-unwrapped.meta // {
    description = stm32cubeide-unwrapped.meta.description + " (FHS wrapper)";
  };
}
