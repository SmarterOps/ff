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

configure_local_path() {
  local marker="# ff: add user install directory to PATH"
  local startup_files=()

  case "${SHELL##*/}" in
    bash)
      startup_files=("$HOME/.profile" "$HOME/.bashrc")
      ;;
    zsh)
      startup_files=("$HOME/.zprofile" "$HOME/.zshrc")
      ;;
    *)
      startup_files=("$HOME/.profile")
      ;;
  esac

  for startup_file in "${startup_files[@]}"; do
    if [[ ! -f "$startup_file" ]] || ! grep -Fq -- "$marker" "$startup_file"; then
      {
        printf '\n%s\n' "$marker"
        printf '%s\n' 'case ":$PATH:" in'
        printf '%s\n' '  *":$HOME/.local/bin:"*) ;;'
        printf '%s\n' '  *) export PATH="$HOME/.local/bin:$PATH" ;;'
        printf '%s\n' 'esac'
      } >> "$startup_file"
    fi
  done
}

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
if [[ "$INSTALL_DIR" == "$HOME/.local/bin" ]]; then
  configure_local_path
fi
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  if [[ "$INSTALL_DIR" == "$HOME/.local/bin" ]]; then
    echo "==> Added $INSTALL_DIR to your shell startup files."
    echo "==> Open a new terminal to use 'ff', or run:"
    echo "    export PATH=\"$INSTALL_DIR:\$PATH\""
  else
    echo "==> Add $INSTALL_DIR to your PATH to run ff from any directory."
  fi
fi
