{ pkgs, lib, ... }:
let
  # TODO: move custom vim plugins to their own file (or git repo)
  extraPlugins = {
    tokyonight-vim = pkgs.vimUtils.buildVimPlugin {
      name = "tokyonight.vim";
      version = "1.0";
      src = pkgs.fetchFromGitHub {
        owner = "ghifarit53";
        repo = "tokyonight-vim";
        rev = "4e82e0f0452a6ce8f387828ec71013015515035a";
        sha256 = "sha256-ui/6xv8PH6KuQ4hG1FNMf6EUdF2wfWPNgG/GMXYvn/8=";
      };
    };
  };
in
{
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-markdown
      extraPlugins.tokyonight-vim
    ];
    extraConfig = ''
      set termguicolors
      set number

      colorscheme tokyonight
      set background=dark
      set conceallevel=2

      autocmd FileType markdown set textwidth=50
    '';
  };
}
