#!/usr/bin/env bash
# Print the services/* directories changed between two revisions as a JSON array.
set -euo pipefail

readonly SERVICES_DIR="services"

usage() {
  echo "usage: ${0##*/} <base-rev> <head-rev>" >&2
}

if [[ $# -ne 2 ]]; then
  usage
  exit 2
fi

base=$1
head=$2

for rev in "$base" "$head"; do
  if ! git rev-parse --verify --quiet "${rev}^{commit}" >/dev/null; then
    echo "unknown revision: ${rev}" >&2
    exit 2
  fi
done

# Three-dot diff compares against the merge base, so commits that landed on the
# base branch after this one forked are not reported as ours.
git diff --name-only "${base}...${head}" -- "${SERVICES_DIR}/" \
  | awk -F/ -v dir="${SERVICES_DIR}" 'NF > 2 && $1 == dir { print $2 }' \
  | sort -u \
  | awk 'BEGIN { printf "[" } { printf "%s\"%s\"", (NR > 1 ? "," : ""), $0 } END { print "]" }'
