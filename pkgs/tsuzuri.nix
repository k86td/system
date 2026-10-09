{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "tsuzuri";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "jaisuriya-11";
    repo = "tsuzuri";
    rev = "v${version}";
    hash = "sha256-TD/t3dM+gvHyhiSiDT0I0S51MGVZbcSC6dI+xYSCJxU=";
  };

  vendorHash = "sha256-PI6f6Z3nTiHXM81AYJP6Ac0TlJzVpt20hHk/Tr+9E2I=";

  subPackages = [ "cmd/tsuzuri" ];

  # Tsuzuri has no keymap configuration (config.json takes only theme and
  # themes_dir), so the Ctrl bindings that clash with the tmux prefix are
  # given <Space> leader equivalents at build time. Upstream already ships a
  # leader for the rest: <Space>w save, <Space>n new, <Space>f find.
  postPatch = ''
    substituteInPlace internal/app/app_keys.go \
      --replace-fail '	case "e":
		return m.focusPane(focusSidebar)' '	case "e":
		return m.focusPane(focusSidebar)
	case "b":
		return m.toggleSidebar()
	case "q":
		return m.requestQuit(false)'

    # Advertise the leader forms in the in-app keymap; the Ctrl bindings still
    # work, they are just unreachable under a default-prefix tmux.
    substituteInPlace internal/app/modal.go \
      --replace-fail '{"Ctrl+B", "Toggle explorer"}' '{"SPC b", "Toggle explorer"}' \
      --replace-fail '{"Ctrl+C", "Quit (asks to save)"}' '{"SPC q", "Quit (asks to save)"}' \
      --replace-fail '{"Ctrl+N", "New note (unsaved tab)"}' '{"SPC n", "New note (unsaved tab)"}' \
      --replace-fail '{"Ctrl+S", "Save (new notes: pick folder)"}' '{"SPC w", "Save (new notes: pick folder)"}' \
      --replace-fail '{"\\ / Ctrl+P", "Find note (opens in this tab)"}' '{"\\ / SPC f", "Find note (opens in this tab)"}'
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = {
    description = "Block-based notebook for the terminal, backed by plain Markdown files";
    homepage = "https://github.com/jaisuriya-11/tsuzuri";
    license = lib.licenses.mit;
    mainProgram = "tsuzuri";
  };
}
