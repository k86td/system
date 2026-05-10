{ pkgs-stable }:

final: prev: {
  vimPlugins = prev.vimPlugins // (prev.callPackage ./vimPlugins { });

  # Use stable versions to avoid CMake 4.0 build issues
  intel-graphics-compiler = pkgs-stable.intel-graphics-compiler;
  intel-compute-runtime = pkgs-stable.intel-compute-runtime;
}
