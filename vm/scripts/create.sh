#!/usr/bin/env bash
set -euo pipefail

if (( $# > 1 )); then
  printf 'Usage: bash vm/scripts/create.sh [linux-lab-NAME]\n' >&2
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
# Check daemon access before launching. Multipass refuses an existing name;
# this script never deletes, restarts, or silently reconfigures that instance.
multipass list >/dev/null
multipass launch 24.04 --name "$name" --cpus 2 --memory 4G --disk 20G \
  --timeout 900 --cloud-init "$root/vm/cloud-init/base.yaml"
bash "$root/vm/scripts/check.sh" "$name"
