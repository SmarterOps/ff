#!/usr/bin/env bash

set -euo pipefail

REPO_USER="${FF_REPO_USER:-YOUR_GITHUB_USERNAME}"
REPO_NAME="ff"
BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/${REPO_USER}/${REPO_NAME}/${BRANCH}/ff"

echo "==> Installing ff..."

download() {
  local url="$1"
  local dest="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$dest"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$dest" "$url"
  else
    echo "Error: Neither 'curl' nor 'wget' is installed." >&2
    exit 1
  fi
}

if [ "$(id -u)" -eq 0 ]; then
  INSTALL_DIR="/usr/local/bin"
  SUDO_CMD=""
elif command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
  INSTALL_DIR="/usr/local/bin"
  SUDO_CMD="sudo"
elif command -v sudo >/dev/null 2>&1 && sudo -v 2>/dev/null; then
  INSTALL_DIR="/usr/local/bin"
  SUDO_CMD="sudo"
else
  INSTALL_DIR="$HOME/.local/bin"
  SUDO_CMD=""
fi

if [ "$INSTALL_DIR" = "$HOME/.local/bin" ]; then
  mkdir -p "$INSTALL_DIR"
fi

TEMP_FILE=$(mktemp)
echo "==> Downloading latest binary from GitHub..."
download "$RAW_URL" "$TEMP_FILE"
chmod +x "$TEMP_FILE"

echo "==> Moving binary to $INSTALL_DIR/ff..."
if [ -n "$SUDO_CMD" ]; then
  $SUDO_CMD mv "$TEMP_FILE" "$INSTALL_DIR/ff"
  $SUDO_CMD chmod +x "$INSTALL_DIR/ff"
else
  mv "$TEMP_FILE" "$INSTALL_DIR/ff"
  chmod +x "$INSTALL_DIR/ff"
fi

echo "==> Successfully installed! Verify by running: ff --help"