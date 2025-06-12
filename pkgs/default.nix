{ pkgs, ... }:
{
  vimPlugins = pkgs.vimPlugins // (pkgs.callPackage ./vimPlugins { });
}
