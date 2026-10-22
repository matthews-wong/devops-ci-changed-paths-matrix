#!/usr/bin/env bash
# Exercises changed-services.sh against throwaway git repositories.
set -euo pipefail

script="$(cd "$(dirname "$0")/.." && pwd)/scripts/changed-services.sh"
workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
failures=0

assert_eq() {
  local name=$1 want=$2 got=$3
  if [[ "$want" == "$got" ]]; then
    echo "ok   - ${name}"
  else
    echo "FAIL - ${name}: want ${want}, got ${got}"
    failures=$((failures + 1))
  fi
}

commit_file() {
  mkdir -p "$(dirname "$1")"
  echo "$RANDOM" >"$1"
  git add "$1"
  git commit -qm "touch $1"
}

cd "$workdir"
git init -q -b main
git config user.name tester
git config user.email tester@example.com
commit_file README.md
base=$(git rev-parse HEAD)

commit_file services/worker/a.txt
commit_file services/api/b.txt
commit_file services/api/nested/c.txt
commit_file docs/notes.md
assert_eq "dedupes and sorts services" '["api","worker"]' "$("$script" "$base" HEAD)"

assert_eq "no changes gives empty array" '[]' "$("$script" HEAD HEAD)"

only_docs=$(git rev-parse HEAD)
commit_file docs/more.md
commit_file services/top-level-file.txt
assert_eq "ignores non-service paths" '[]' "$("$script" "$only_docs" HEAD)"

if "$script" "$base" no-such-rev 2>/dev/null; then
  assert_eq "unknown revision fails" "exit 2" "exit 0"
else
  assert_eq "unknown revision fails" 2 $?
fi

exit "$failures"
