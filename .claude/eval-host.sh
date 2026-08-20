#!/usr/bin/env bash
# Evaluate a host's system closure (instantiate only — nothing is built).
#
#   .claude/eval-host.sh [hostname]      # defaults to lenoovo-pad
#
# Why this exists: Nix fetches `github:` flake inputs as tarballs from
# codeload.github.com, which the Claude Code web sandbox's egress policy blocks, while
# plain git reads are allowed. So this evaluates against a scratch copy of the repo whose
# lock points at the *same revisions* over git+https. The repo's own flake.lock is never
# modified. Outside the sandbox this indirection is unnecessary — just run
#   nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath
set -euo pipefail

host="${1:-lenoovo-pad}"
repo="$(git rev-parse --show-toplevel)"
scratch="${TMPDIR:-/tmp}/nix-eval-${host}"

rm -rf "$scratch"
mkdir -p "$scratch"
git -C "$repo" archive HEAD | tar -x -C "$scratch"
# Include uncommitted work, so this checks the tree you are actually editing.
git -C "$repo" diff HEAD --binary | (cd "$scratch" && git apply --allow-empty -) 2>/dev/null || true

python3 - "$scratch/flake.lock" <<'PY'
import json, sys
path = sys.argv[1]
lock = json.load(open(path))
for node in lock["nodes"].values():
    locked = node.get("locked")
    if not locked:
        continue
    # Only the `locked` entry is rewritten. `original` must keep matching flake.nix or
    # Nix considers the lock stale and re-resolves it against the GitHub API.
    if locked.get("type") == "github":
        node["locked"] = {
            "type": "git",
            "url": f"https://github.com/{locked['owner']}/{locked['repo']}",
            "rev": locked["rev"],
            "shallow": True,
            "lastModified": locked.get("lastModified"),
        }
    elif locked.get("type") == "git":
        locked["shallow"] = True
json.dump(lock, open(path, "w"), indent=2)
PY

export NIX_SSL_CERT_FILE="${NIX_SSL_CERT_FILE:-/root/.ccr/ca-bundle.crt}"
exec nix eval --no-write-lock-file \
  "path:${scratch}#nixosConfigurations.${host}.config.system.build.toplevel.drvPath"
