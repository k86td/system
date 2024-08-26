{ pkgs, ... }:
{
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-markdown
    ];
    extraConfig = ''
      colorscheme habamax
      set background=dark
      set conceallevel=2

      autocmd FileType markdown set textwidth=50
    '';
  };
}
