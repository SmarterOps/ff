#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TEST_DIR"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

PACKAGE_DIR="$TEST_DIR/package"
mkdir -p "$PACKAGE_DIR"
cp "$SCRIPT_DIR/install.sh" "$PACKAGE_DIR/install.sh"
cp "$SCRIPT_DIR/ff" "$PACKAGE_DIR/ff"

LOCAL_INSTALL="$TEST_DIR/local-bin"
(
  cd "$TEST_DIR"
  FF_INSTALL_DIR="$LOCAL_INSTALL" bash "$PACKAGE_DIR/install.sh"
) >/dev/null
[[ -x "$LOCAL_INSTALL/ff" ]] || fail "local install did not create an executable"
"$LOCAL_INSTALL/ff" --version >/dev/null

REMOTE_PACKAGE="$TEST_DIR/remote-package"
MOCK_BIN="$TEST_DIR/mock-bin"
mkdir -p "$REMOTE_PACKAGE" "$MOCK_BIN"
cp "$SCRIPT_DIR/install.sh" "$REMOTE_PACKAGE/install.sh"

cat > "$MOCK_BIN/curl" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
[[ "$1" == "-fsSL" && "$3" == "-o" ]]
cat "$FF_TEST_SOURCE" > "$4"
MOCK
chmod +x "$MOCK_BIN/curl"

CURL_INSTALL="$TEST_DIR/curl-bin"
(
  FF_INSTALL_DIR="$CURL_INSTALL" \
  FF_TEST_SOURCE="$SCRIPT_DIR/ff" \
  PATH="$MOCK_BIN:$PATH" \
  bash "$REMOTE_PACKAGE/install.sh"
) >/dev/null
[[ -x "$CURL_INSTALL/ff" ]] || fail "curl remote install did not create an executable"
"$CURL_INSTALL/ff" --version >/dev/null

WGET_PATH="$TEST_DIR/wget-path"
mkdir -p "$WGET_PATH"
for tool in bash dirname mkdir mktemp install chmod mv rm cat env; do
  ln -s "$(command -v "$tool")" "$WGET_PATH/$tool"
done
cat > "$WGET_PATH/wget" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
[[ "$1" == "-q" && "$2" == "-O" ]]
cat "$FF_TEST_SOURCE" > "$3"
MOCK
chmod +x "$WGET_PATH/wget"

WGET_INSTALL="$TEST_DIR/wget-bin"
(
  FF_INSTALL_DIR="$WGET_INSTALL" \
  FF_TEST_SOURCE="$SCRIPT_DIR/ff" \
  PATH="$WGET_PATH" \
  bash "$REMOTE_PACKAGE/install.sh"
) >/dev/null
[[ -x "$WGET_INSTALL/ff" ]] || fail "wget remote install did not create an executable"
"$WGET_INSTALL/ff" --version >/dev/null

LOCAL_HOME="$TEST_DIR/local-home"
LOCAL_PATH_INSTALL="$LOCAL_HOME/.local/bin"
mkdir -p "$LOCAL_HOME"
(
  HOME="$LOCAL_HOME" \
  SHELL="/bin/bash" \
  FF_INSTALL_DIR="$LOCAL_PATH_INSTALL" \
    bash "$PACKAGE_DIR/install.sh"
) >/dev/null
[[ -x "$LOCAL_PATH_INSTALL/ff" ]] || fail "local user install did not create an executable"
grep -Fq '# ff: add user install directory to PATH' "$LOCAL_HOME/.profile" ||
  fail "local user install did not configure the login shell PATH"
grep -Fq '# ff: add user install directory to PATH' "$LOCAL_HOME/.bashrc" ||
  fail "local user install did not configure the interactive Bash PATH"
(
  HOME="$LOCAL_HOME" \
  SHELL="/bin/bash" \
  FF_INSTALL_DIR="$LOCAL_PATH_INSTALL" \
    bash "$PACKAGE_DIR/install.sh"
) >/dev/null
[[ "$(grep -Fc '# ff: add user install directory to PATH' "$LOCAL_HOME/.profile")" == 1 ]] ||
  fail "local user install duplicated the login shell PATH configuration"
[[ "$(grep -Fc '# ff: add user install directory to PATH' "$LOCAL_HOME/.bashrc")" == 1 ]] ||
  fail "local user install duplicated the interactive Bash PATH configuration"

PRESERVE_INSTALL="$TEST_DIR/preserve-bin"
mkdir -p "$PRESERVE_INSTALL"
cat > "$PRESERVE_INSTALL/ff" <<'EXISTING'
#!/usr/bin/env bash
echo preserved-install
EXISTING
chmod +x "$PRESERVE_INSTALL/ff"

cat > "$MOCK_BIN/curl" <<'MOCK'
#!/usr/bin/env bash
exit 22
MOCK
chmod +x "$MOCK_BIN/curl"

if (
  FF_INSTALL_DIR="$PRESERVE_INSTALL" \
  PATH="$MOCK_BIN:$PATH" \
  bash "$REMOTE_PACKAGE/install.sh"
) >/dev/null 2>&1; then
  fail "failed remote download should fail installation"
fi
[[ "$("$PRESERVE_INSTALL/ff")" == "preserved-install" ]] ||
  fail "failed download replaced the existing install"

printf 'invalid shell syntax (\n' > "$TEST_DIR/invalid-ff"
cat > "$MOCK_BIN/curl" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
cat "$FF_TEST_SOURCE" > "$4"
MOCK
chmod +x "$MOCK_BIN/curl"

if (
  FF_INSTALL_DIR="$PRESERVE_INSTALL" \
  FF_TEST_SOURCE="$TEST_DIR/invalid-ff" \
  PATH="$MOCK_BIN:$PATH" \
  bash "$REMOTE_PACKAGE/install.sh"
) >/dev/null 2>&1; then
  fail "invalid downloaded script should fail installation"
fi
[[ "$("$PRESERVE_INSTALL/ff")" == "preserved-install" ]] ||
  fail "invalid download replaced the existing install"

echo "All installer tests passed."
