# Evidence: #1 L1.1 VM baseline

- Issue / PR: https://github.com/anton415/linux-lab/issues/1
- Date: 2026-10-03
- linux-lab commit: af1cbbf08a344790b514afb7ee238d858037d903
- finance-lab commit, if used: not used
- Host OS/architecture; VM tool/version/driver: macOS on Apple Silicon (Mac mini M4 Pro); Multipass 1.16.4+mac; qemu
- Guest release/architecture/image identifier: Ubuntu 24.04.5 LTS; Apple Silicon guest architecture; image hash 1d6bffe64b84 (Ubuntu 24.04 LTS)
- Relevant package/tool versions: cloud-init 26.1-0ubuntu1~24.04.1; other package versions not yet recorded
- Reproduction instructions and fixture: from repository root at the commit above, run `bash vm/scripts/create.sh linux-lab-01` with the checked-in `vm/cloud-init/base.yaml`. The first observed run was performed while RedShield VPN was enabled.

## Observations

| Command or check | Expected | Observed / exit status | Result |
|---|---|---|---|
| `git status --short` | Clean working tree before the first VM attempt | No output | pass |
| `multipass version` | Multipass available | `multipass 1.16.4+mac`, `multipassd 1.16.4+mac` | pass |
| `multipass get local.driver` | Known VM driver | `qemu` | pass |
| `bash vm/scripts/create.sh linux-lab-01` | VM created, cloud-init completes, guest checks pass | VM launched, then `status: error` from cloud-init | fail |
| `multipass info linux-lab-01` | Determine whether VM itself booted | VM was `Running`; Ubuntu 24.04.5 LTS; 2 CPUs; about 3.8 GiB RAM; 19.3 GiB disk | pass |
| `multipass exec linux-lab-01 -- sudo cloud-init status --long` | Cloud-init completes successfully | `status: error`; package installer reported failures for `shellcheck` and `dnsutils`; schema warning also reported | fail |
| `multipass exec linux-lab-01 -- sudo cloud-init schema --system` | Valid user-data schema | `write_files.0.permissions: 420 is not of type 'string'` | fail |
| `multipass exec linux-lab-01 -- sudo grep -n 'permissions' /var/lib/cloud/instances/linux-lab-01/cloud-config.txt` | Guest receives permissions as a string | Guest received `permissions: 420` | fail |
| `multipass exec linux-lab-01 -- sudo journalctl -u cloud-final --no-pager -n 100` | Package repositories reachable and packages install | Connections to `ports.ubuntu.com:80` timed out; package installation failed | fail |
| `multipass exec linux-lab-01 -- getent hosts example.com` with RedShield enabled | DNS resolution works | Returned addresses for `example.com` | pass |
| `curl -I --max-time 10 http://ports.ubuntu.com/ubuntu-ports/` on the Mac with RedShield enabled | Host can reach Ubuntu repository | `HTTP/1.1 200 OK` | pass |
| `multipass exec linux-lab-01 -- curl -I --max-time 10 http://ports.ubuntu.com/ubuntu-ports/` with RedShield enabled | Guest can reach Ubuntu repository | Timed out | fail |
| `multipass exec linux-lab-01 -- curl -I --max-time 10 https://ports.ubuntu.com/ubuntu-ports/` with RedShield enabled | Guest HTTPS works | Timed out | fail |
| `multipass exec linux-lab-01 -- curl -I --max-time 10 https://example.com/` with RedShield enabled | General guest HTTPS works | Timed out | fail |
| Same `https://example.com/` guest curl after temporarily disconnecting RedShield | Determine whether VPN state affects guest connectivity | `HTTP/2 200` | pass |

## Failure and recovery

- Initial hypothesis and commands chosen by Anton:
  - Anton first identified that cloud-init appeared to have failed while installing packages.
  - He checked the VM state separately and confirmed that the VM itself was running.
- Bounded fault introduced and diagnostic evidence:
  - No artificial fault was introduced. The first real VM attempt exposed two bounded failures.
  - Cloud-init schema validation showed that the checked-in string permission `'0644'` arrived in the guest as integer `420`.
  - Package installation failed because outbound connections from the guest timed out while RedShield VPN was enabled.
  - DNS resolution inside the guest still worked.
  - The same guest successfully reached `https://example.com/` after RedShield was temporarily disconnected.
- Cause established by evidence:
  1. Under the current macOS/QEMU/RedShield setup, RedShield interferes with outbound network connectivity from the Multipass guest. This is an environment-specific observation, not a general claim about every RedShield or Multipass configuration.
  2. Separately, the cloud-init data received by the guest contains `permissions: 420` instead of a string permission value, causing schema validation to fail.
- Repair, verification, and cleanup:
  - Not performed yet. The failed instance is intentionally retained for evidence and diagnosis.
  - No manual package installation or in-guest repair has been used.

## Recreation

- Fresh VM result: not yet run after diagnosis/fix
- Second host result, or explicitly not tested: not tested
- Differences and known limits:
  - The first run was performed with RedShield VPN enabled.
  - Guest Internet access succeeded when RedShield was temporarily disconnected.
  - A clean corrected rebuild is still required before issue #1 can pass.

## Human demonstration

- What Anton did without a supplied solution:
  - Read the repository VM flow and explained the roles of Multipass, cloud-init, `create.sh`, `check.sh`, and `guest-check.sh`.
  - Identified the package-installation failure from cloud-init output.
  - Confirmed separately that the VM was running and that DNS resolution worked.
  - Repeated controlled connectivity tests with and without RedShield.
- Explanation in his own words:
  - Anton identified that the VM itself had started, but cloud-init failed to install some packages. Subsequent checks separated that from the VPN-related outbound-connectivity failure.
- AI assistance used:
  - ChatGPT explained the repository flow, suggested bounded diagnostic commands, and helped interpret the resulting logs. Anton executed the commands and provided the observations.
- Remaining acceptance criteria / decision:
  - Fix the cloud-init permission typing issue in repository configuration.
  - Create a clean VM with working package access.
  - Verify `check.sh` passes, restart and re-check the VM, then create and verify `linux-lab-rebuild`.
  - Record final package/tool versions, actual time spent, and complete the independent human explanation before review.
