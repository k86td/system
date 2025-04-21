{ pkgs, lib, ... }:
let
  # TODO: move custom vim plugins to their own file (or git repo)
  extraPlugins = {
    vim-transparent = pkgs.vimUtils.buildVimPlugin {
      name = "vim-transparent";
      src = pkgs.fetchFromGitHub {
        owner = "tribela";
        repo = "vim-transparent";
        rev = "7b34267";
        sha256 = "sha256-zEH5A9CKaoN5DXJjmC0+j74kBZsfJm+Ztk1qFHeIzts=";
      };
    };
  };
in
{
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      extraPlugins.vim-transparent
      nerdtree
      vim-floaterm

      # markdown plugins
      vim-markdown
      markdown-preview-nvim
    ];
    settings = {
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
    };
    extraConfig = ''
      set termguicolors
      set number

      colorscheme industry
      set conceallevel=2

      autocmd FileType markdown set textwidth=50

      nmap <Space>e :NERDTreeToggle <Enter>

      let g:floaterm_keymap_toggle = '<C-_>'
      let g:floaterm_shell = 'zsh'
    '';
  };
}
