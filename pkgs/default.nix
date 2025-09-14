final: prev: {
  vimPlugins = prev.vimPlugins // (prev.callPackage ./vimPlugins { });
  fonts-tiempos = prev.callPackage ./fonts-tiempos { };
}
