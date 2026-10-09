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
