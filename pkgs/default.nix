{ pkgs-stable }:

final: prev: {
  vimPlugins = prev.vimPlugins // (prev.callPackage ./vimPlugins { });
  fonts-tiempos = prev.callPackage ./fonts-tiempos { };
  stm32cubeide-unwrapped = prev.callPackage ./stm32cubeide { };
  stm32cubeide = prev.callPackage ./stm32cubeide/fhs.nix {
    stm32cubeide-unwrapped = final.stm32cubeide-unwrapped;
  };

  # Use stable versions to avoid CMake 4.0 build issues
  intel-graphics-compiler = pkgs-stable.intel-graphics-compiler;
  intel-compute-runtime = pkgs-stable.intel-compute-runtime;
}
