#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Setting up development environment with Nix and home-manager..."

# Set up Nix store in home directory for persistence
export NIX_ROOT="$HOME/.nix"
export NIX_STORE_DIR="$NIX_ROOT/store"
export NIX_STATE_DIR="$NIX_ROOT/var/nix"
export NIX_LOG_DIR="$NIX_ROOT/var/log/nix"

# Install Nix if not present (single-user install in home directory)
if ! command -v nix &> /dev/null; then
    echo "📦 Installing Nix in $NIX_ROOT..."
    
    # Use single-user installation to avoid daemon/root requirements
    sh <(curl -L https://nixos.org/nix/install) --no-daemon
    
    # Source Nix for current session
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# Ensure Nix is sourced for this session
if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# Configure Nix for flakes
mkdir -p ~/.config/nix
cat > ~/.config/nix/nix.conf <<EOF
experimental-features = nix-command flakes
# Keep builds in user space
build-users-group = 
sandbox = false
EOF

# Get the dotfiles directory
DOTFILES_DIR="$HOME/dotfiles"
cd "$DOTFILES_DIR"

echo "🏠 Installing home-manager configuration..."

# Install home-manager and switch to configuration
nix run home-manager/master -- switch --flake ".#ebox-tlepine" --impure

echo "done!"
