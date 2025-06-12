{ lib, vimUtils, fetchFromGitHub }:
vimUtils.buildVimPlugin {
  pname = "claudecode.nvim";
  version = "0.1.0"

  src = fetchFromGitHub {
    owner = "coder";
    repo = "claudecode.nvim";
    rev = "0.1.0";
    sha256= lib.fakeSha256;
  }

  meta = with lib; {
    description = "Claude Code Vim plugin";
    homepage = "https://github.com/coder/claudecode.nvim";
    license = licenses.mit;
  }
}

