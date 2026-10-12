#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="${FF_INSTALL_DIR:-/usr/local/bin}"

ensure_install_dir() {
  if [[ -d "$INSTALL_DIR" && -w "$INSTALL_DIR" ]]; then
    return 0
  fi

  mkdir -p "$INSTALL_DIR" 2>/dev/null || {
    local fallback_dir="$HOME/.local/bin"
    mkdir -p "$fallback_dir"
    INSTALL_DIR="$fallback_dir"
  }

  if [[ ! -w "$INSTALL_DIR" ]]; then
    echo "==> Cannot write to $INSTALL_DIR. Falling back to $HOME/.local/bin"
    mkdir -p "$HOME/.local/bin"
    INSTALL_DIR="$HOME/.local/bin"
  fi
}

install_binary() {
  local source="$1"
  local target="$INSTALL_DIR/ff"

  install -m 755 "$source" "$target"
  echo "==> Installed ff to: $target"
}

echo "==> Installing ff..."
ensure_install_dir

if [ -f "./ff" ]; then
  echo "==> Found local ff file, installing directly..."
  install_binary "./ff"
  echo "==> Successfully installed! Verify by running: ff --help"
  if [[ "$INSTALL_DIR" != "/usr/local/bin" ]]; then
    echo "==> Tip: add $INSTALL_DIR to your PATH if needed."
  fi
  exit 0
fi

REPO_USER="${FF_REPO_USER:-}"
if [[ -z "$REPO_USER" ]]; then
  echo "==> FF_REPO_USER is not set. Please set it or run this script from a repository containing ./ff"
  echo "==> Example: FF_REPO_USER=your-github-username ./install.sh"
  exit 1
fi

RAW_URL="https://raw.githubusercontent.com/${REPO_USER}/ff/main/ff"

if ! command -v curl >/dev/null 2>&1; then
  echo "==> curl is required to download ff from GitHub."
  exit 1
fi

echo "==> Downloading latest binary from GitHub..."
curl -fsSL "$RAW_URL" -o "$INSTALL_DIR/ff"
chmod +x "$INSTALL_DIR/ff"

echo "==> Successfully installed! Verify by running: ff --help"
if [[ "$INSTALL_DIR" != "/usr/local/bin" ]]; then
  echo "==> Tip: add $INSTALL_DIR to your PATH if needed."
fi
