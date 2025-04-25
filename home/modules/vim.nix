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

    fuzzyy = pkgs.vimUtils.buildVimPlugin {
      name = "fuzzyy";
      src = pkgs.fetchFromGitHub {
        owner = "Donaldttt";
        repo = "fuzzyy";
        rev = "f424831";
        sha256 = "sha256-DzUsEHDOvelN0d1lymesopMI8nVtE5bjv6Zx6aYv2hI=";
      };
    };
  };
in
{
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      extraPlugins.vim-transparent
      extraPlugins.fuzzyy
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
      
      let g:fuzzyy_enable_mappings = 0
      nmap fb :FuzzyBuffers <Enter>
      nmap ff :FuzzyFiles <Enter>
      nmap fg :FuzzyGrep <Enter>
    '';
  };
}
