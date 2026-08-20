#!/usr/bin/env bash
# SessionStart hook: install Nix so the flake can be evaluated in Claude Code on the web.
#
# The container image is cached after this hook completes, so the install cost is paid
# once per environment rather than once per session.
set -euo pipefail

# Local machines already have their own Nix; only set it up in the remote container.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

NIX_BIN="${HOME:-/root}/.nix-profile/bin"
CA_BUNDLE="/root/.ccr/ca-bundle.crt"

# Nix does not read the standard CA env vars, and outbound HTTPS is re-terminated by the
# agent proxy, so it needs NIX_SSL_CERT_FILE pointed at the proxy bundle explicitly.
persist_env() {
  if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
    echo "export PATH=\"${NIX_BIN}:\$PATH\"" >> "$CLAUDE_ENV_FILE"
    if [ -f "$CA_BUNDLE" ]; then
      echo "export NIX_SSL_CERT_FILE=\"${CA_BUNDLE}\"" >> "$CLAUDE_ENV_FILE"
    fi
  fi
}

# Idempotent: the hook also runs on resume/clear/compact, and /nix survives in the
# cached image, so re-entering just re-exports the environment.
if [ -x "${NIX_BIN}/nix" ]; then
  persist_env
  exit 0
fi

# This must exist *before* the installer runs. A single-user install as root aborts with
# "the group 'nixbld' specified in 'build-users-group' does not exist" otherwise, and
# there is no systemd here to run a multi-user daemon. With no build users, builds run as
# root and the sandbox cannot be set up, hence sandbox = false — acceptable in a
# throwaway container that is only evaluating and building this flake.
mkdir -p /etc/nix
cat > /etc/nix/nix.conf <<'CONF'
build-users-group =
experimental-features = nix-command flakes
sandbox = false
CONF

if [ -f "$CA_BUNDLE" ]; then
  export NIX_SSL_CERT_FILE="$CA_BUNDLE"
  export SSL_CERT_FILE="$CA_BUNDLE"
fi

# Both steps reach the network, and a single flaky TLS handshake should not take the
# whole session down with it.
retry() {
  local attempt
  for attempt in 1 2 3; do
    if "$@"; then
      return 0
    fi
    echo "session-start: '$1' failed (attempt ${attempt}/3), retrying..." >&2
    sleep $((attempt * 5))
  done
  return 1
}

installer="$(mktemp)"
retry curl -fsSL https://nixos.org/nix/install -o "$installer"
retry sh "$installer" --no-daemon
rm -f "$installer"

persist_env
