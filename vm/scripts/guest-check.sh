#!/usr/bin/env bash
set -euo pipefail

# Read-only checks inside the guest. Output contains no host paths or IPs.
if [[ $(uname -s) != Linux ]]; then
  printf 'This check must run inside the Ubuntu guest.\n' >&2
  exit 1
fi
# shellcheck source=/dev/null
source /etc/os-release
[[ $ID == ubuntu && $VERSION_ID == 24.04 ]]
[[ $(cat /proc/1/comm) == systemd ]]
grep -Fxq 'linux-lab baseline v1' /etc/linux-lab-baseline
for tool in curl dig git ip jq lsof python3 shellcheck ufw; do
  command -v "$tool" >/dev/null
done
systemctl is-active --quiet ssh
sudo -n /usr/sbin/sshd -T | grep -Fxq 'passwordauthentication no'
printf 'PASS: Ubuntu %s; architecture %s; systemd; baseline tools; SSH key authentication.\n' \
  "$VERSION_ID" "$(uname -m)"
