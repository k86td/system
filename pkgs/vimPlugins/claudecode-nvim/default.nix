{ lib, vimUtils, fetchFromGitHub }:
vimUtils.buildVimPlugin {
  pname = "claudecode.nvim";
  version = "v0.1.0";

  src = fetchFromGitHub {
    owner = "coder";
    repo = "claudecode.nvim";
    rev = "v0.1.0";
    sha256 = "sha256-oWUO9DfckZuFXmMcW3Y/gEF2EbFD/lE2Vt2YzANkrWo=";
  };

  meta = with lib; {
    description = "Claude Code Vim plugin";
    homepage = "https://github.com/coder/claudecode.nvim";
    license = licenses.mit;
  };
}