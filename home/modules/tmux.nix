{ pkgs, ... }:
let
  minimal-tmux-status = pkgs.tmuxPlugins.mkTmuxPlugin {
    name = "minimal-tmux-status";
    pluginName = "minimal";
    src = pkgs.fetchFromGitHub {
      owner = "niksingh710";
      repo = "minimal-tmux-status";
      rev = "86de1697b6b0522ebd36b5fe83c5fd9b7e30f15f";
      hash = "sha256-lDPT3XRH14Z5WTdtWhgiYa8FjQHeYFCY7Dpy9xU8vyM=";
    };
  };
in
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.nushell}/bin/nu";
    extraConfig = ''
      bind -n M-t new-window

      bind -n M-l next-layout
      bind -n M-w kill-pane

      bind -n M-s split-window

      bind -n M-Right select-pane -R
      bind -n M-Left select-pane -L
      bind -n M-Down select-pane -D
      bind -n M-Up select-pane -U

      bind -n M-q previous-window
      bind -n M-e next-window

      bind -n M-r command-prompt -I "#W" "rename-window -- '%%'"

      bind-key -T root M-/ copy-mode
      bind-key -T copy-mode M-/ send-keys -X cancel

      bind-key -T copy-mode C-v send-keys -X begin-selection
      bind-key -T copy-mode C-c send-keys -X clear-selection

      bind-key -T copy-mode C-y send-keys -X copy-selection-and-cancel
      bind -n C-p paste-buffer

      set -g default-terminal "tmux-256color"
      set -ga terminal-overrides ",alacritty:RGB"
      set -ga terminal-overrides ",*256col*:Tc"

      set -g set-titles on
      set -g set-titles-string "tmux - #S"

      set -sg escape-time 0
    '';
    plugins = [
      minimal-tmux-status
    ];
  };
}
