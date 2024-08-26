{pkgs}:
{
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-markdown

      # colorscheme
      papercolor-theme
    ];
    extraConfig = ''
      colorscheme PaperColor
      set background=dark
      set conceallevel=2

      autocmd FileType markdown set textwidth=50
    '';
  };
}
