#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
FF="$SCRIPT_DIR/ff"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TEST_DIR"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_exists() {
  [[ -e "$1" ]] || fail "expected path to exist: $1"
}

assert_contains() {
  [[ "$1" == *"$2"* ]] || fail "expected output to contain: $2"
}

mkdir -p "$TEST_DIR/work"
cd "$TEST_DIR/work"

output="$("$FF" project/src project/tests)"
assert_exists "project/src"
assert_exists "project/tests"
assert_contains "$output" "[FOLDER CREATED]"

output="$("$FF" project/src/main.js project/package.json)"
assert_exists "project/src/main.js"
assert_exists "project/package.json"
assert_contains "$output" "[FILE CREATED]"

"$FF" "project folder/notes file.txt" >/dev/null
assert_exists "project folder/notes file.txt"

"$FF" --dir project/config.v2 >/dev/null
[[ -d "project/config.v2" ]] || fail "dotted directory was not created"

"$FF" --file project/.env >/dev/null
[[ -f "project/.env" ]] || fail "explicit file was not created"

"$FF" -- --leading-dash >/dev/null
assert_exists "--leading-dash"

output="$("$FF" project/src)"
assert_contains "$output" "[ALREADY EXISTS]"
output="$("$FF" project/package.json)"
assert_contains "$output" "[ALREADY EXISTS]"

if "$FF" --file >/dev/null 2>&1; then
  fail "--file without a path should fail"
fi

if "$FF" --file --no-color >/dev/null 2>&1; then
  fail "--file followed by an option should fail"
fi

if "$FF" --dir >/dev/null 2>&1; then
  fail "--dir without a path should fail"
fi

if "$FF" --no-color >/dev/null 2>&1; then
  fail "--no-color without a path should fail"
fi

if "$FF" "" >/dev/null 2>&1; then
  fail "empty path should fail"
fi

"$FF" project/no-color.txt --no-color >/dev/null
assert_exists "project/no-color.txt"

"$FF" -- --draft.txt >/dev/null
assert_exists "--draft.txt"

assert_contains "$("$FF" --version)" "ff "
assert_contains "$("$FF" --help)" "Examples:"

echo "All ff tests passed."
