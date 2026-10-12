cat << 'EOF' > install.sh
#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="/usr/local/bin"

echo "==> Installing ff..."

# Agar local folder mein 'ff' already maujood hai
if [ -f "./ff" ]; then
  echo "==> Found local ff file, installing directly..."
  cp ./ff "$INSTALL_DIR/ff"
  chmod +x "$INSTALL_DIR/ff"
  echo "==> Successfully installed! Verify by running: ff --help"
  exit 0
fi

# Agar remote se install ho raha ho
REPO_USER="${FF_REPO_USER:-YOUR_GITHUB_USERNAME}"
RAW_URL="https://raw.githubusercontent.com/${REPO_USER}/ff/main/ff"

echo "==> Downloading latest binary from GitHub..."
curl -fsSL "$RAW_URL" -o "$INSTALL_DIR/ff"
chmod +x "$INSTALL_DIR/ff"

echo "==> Successfully installed! Verify by running: ff --help"
EOF
