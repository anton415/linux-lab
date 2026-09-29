#!/usr/bin/env bash
set -euo pipefail

if (( $# > 1 )); then
  printf 'Usage: bash vm/scripts/check.sh [linux-lab-NAME]\n' >&2
  exit 2
fi
name=${1:-linux-lab-01}
if [[ ! $name =~ ^linux-lab-[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  printf 'Use a name such as linux-lab-01 or linux-lab-rebuild.\n' >&2
  exit 2
fi
if ! command -v multipass >/dev/null 2>&1; then
  printf 'Multipass is required. See docs/vm.md for host setup.\n' >&2
  exit 1
fi

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
multipass exec "$name" -- sudo timeout 600 cloud-init status --wait
multipass exec "$name" -- bash -s < "$root/vm/scripts/guest-check.sh"
