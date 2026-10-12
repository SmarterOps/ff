#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${FF_INSTALL_DIR:-/usr/local/bin}"
SOURCE_FILE="$SCRIPT_DIR/ff"
REPO_USER="${FF_REPO_USER:-SmarterOps}"
RAW_URL="https://raw.githubusercontent.com/${REPO_USER}/ff/main/ff"

if ! mkdir -p "$INSTALL_DIR" 2>/dev/null || [[ ! -w "$INSTALL_DIR" ]]; then
  INSTALL_DIR="$HOME/.local/bin"
  mkdir -p "$INSTALL_DIR"
fi

TEMP_FILE="$(mktemp "$INSTALL_DIR/.ff.XXXXXX")"
trap 'rm -f -- "$TEMP_FILE"' EXIT

if [[ -f "$SOURCE_FILE" ]]; then
  echo "==> Installing local ff..."
  install -m 755 "$SOURCE_FILE" "$TEMP_FILE"
else
  echo "==> Downloading ff from $RAW_URL..."
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$RAW_URL" -o "$TEMP_FILE"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$TEMP_FILE" "$RAW_URL"
  else
    echo "ff: remote installation requires curl or wget." >&2
    exit 1
  fi
  chmod 755 "$TEMP_FILE"
fi

if ! bash -n "$TEMP_FILE"; then
  echo "ff: downloaded or copied file failed Bash syntax validation; installation cancelled." >&2
  exit 1
fi

mv -f -- "$TEMP_FILE" "$INSTALL_DIR/ff"
trap - EXIT

echo "==> Installed ff to: $INSTALL_DIR/ff"
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  echo "==> Add $INSTALL_DIR to your PATH to run ff from any directory."
fi
