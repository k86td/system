{ pkgs, ... }:
{
  vimPlugins = pkgs.vimPlugins // (import ./vimPlugins { inherit pkgs; });
}
