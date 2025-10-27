{ lib
, buildFHSEnv
, stm32cubeide-unwrapped
, librsvg
, shared-mime-info
, gsettings-desktop-schemas
, gtk3
, hicolor-icon-theme
, adwaita-icon-theme
}:

buildFHSEnv {
  name = "stm32cubeide";

  # Allow accessing any directory by running from $HOME
  extraBwrapArgs = [
    "--chdir $HOME"
  ];

  targetPkgs = pkgs: (with pkgs; [
    stm32cubeide-unwrapped
    gtk3
    webkitgtk_4_1
    libsecret
    xorg.libXtst
    ncurses5
    qt6.qtwayland
    alsa-lib
    libxkbcommon
    xorg.libXxf86vm
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
    librsvg
    atk
    shared-mime-info
    gsettings-desktop-schemas
    hicolor-icon-theme
    adwaita-icon-theme
  ]);

  # Set up environment for proper GTK and Java operation
  profile = ''
    export GDK_PIXBUF_MODULE_FILE=${librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
    export XDG_DATA_DIRS=${shared-mime-info}/share:${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:${hicolor-icon-theme}/share:${adwaita-icon-theme}/share:$XDG_DATA_DIRS
  '';

  runScript = "stm32cubeide";

  meta = stm32cubeide-unwrapped.meta // {
    description = stm32cubeide-unwrapped.meta.description + " (FHS wrapper)";
  };
}
