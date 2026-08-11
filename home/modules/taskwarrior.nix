{ pkgs, ... }:
let
  tw-note = pkgs.writeShellApplication {
    name = "tw-note";
    runtimeInputs = [
      pkgs.taskwarrior3
      pkgs.helix
    ];
    text = ''
      if [ "$#" -ne 1 ]; then
        echo "tw-note: expected exactly 1 task uuid, got $#" >&2
        exit 1
      fi

      uuid="$1"
      dir="$HOME/notes/tasks"
      path="$dir/tw-$uuid.md"

      mkdir -p "$dir"

      if [ ! -f "$path" ]; then
        desc="$(task _get "$uuid".description)"
        printf '# %s\n\n' "$desc" > "$path"
        task "$uuid" modify +note >/dev/null
      fi

      exec hx "$path"
    '';
  };
in
{
  programs.taskwarrior = {
    enable = true;
    colorTheme = "dark-256";
    package = pkgs.taskwarrior3;
    dataLocation = "/home/tlepine/.task";
    config = {
      "uda.taskwarrior-tui.shortcuts.1" = "${tw-note}/bin/tw-note";
      "color.tag.note" = "color244";
    };
  };

  home.packages = [
    pkgs.taskwarrior-tui
    tw-note
  ];
}
