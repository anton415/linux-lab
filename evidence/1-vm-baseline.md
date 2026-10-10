# Evidence: #1 L1.1 VM baseline

- Issue / PR: https://github.com/anton415/linux-lab/issues/1
- Date: 2026-10-03
- Verified linux-lab commit: 771a5e2ab814588d3331ec9a73371b73ac037677
- Initial failing source commit: af1cbbf08a344790b514afb7ee238d858037d903
- finance-lab commit, if used: not used
- Planned / actual time: 1h30m / 3h45m
- Host OS/architecture; VM tool/version/driver: macOS on Apple Silicon (Mac mini M4 Pro); Multipass 1.16.4+mac; qemu
- Guest release/architecture/image identifier: Ubuntu 24.04.5 LTS; aarch64; image hash 1d6bffe64b84 (Ubuntu 24.04 LTS)
- Relevant package/tool versions: cloud-init 26.1-0ubuntu1~24.04.1; curl 8.5.0-2ubuntu10.15; dnsutils 1:9.18.39-0ubuntu0.24.04.7; git 1:2.43.0-1ubuntu7.3; iproute2 6.1.0-1ubuntu6.4; jq 1.7.1-3ubuntu0.24.04.2; lsof 4.95.0-1build3; python3 3.12.3-0ubuntu2.1; shellcheck 0.9.0-1; ufw 0.36.2-6
- Reproduction instructions and fixture: from repository root at the verified commit above, temporarily disconnect RedShield while guest Internet access is required, then run `bash vm/scripts/create.sh linux-lab-01` and `bash vm/scripts/create.sh linux-lab-rebuild`. Both use the checked-in `vm/cloud-init/base.yaml`.

## Observations

| Command or check | Expected | Observed / exit status | Result |
|---|---|---|---|
| `git status --short` before the first VM attempt | Clean working tree | No output | pass |
| `multipass version` | Multipass available | `multipass 1.16.4+mac`, `multipassd 1.16.4+mac` | pass |
| `multipass get local.driver` | Known VM driver | `qemu` | pass |
| Initial `bash vm/scripts/create.sh linux-lab-01` at `af1cbbf` | VM created, cloud-init completes, guest checks pass | VM launched, then `status: error` from cloud-init | fail |
| `multipass info linux-lab-01` after initial failure | Determine whether VM itself booted | VM was `Running`; Ubuntu 24.04.5 LTS; 2 CPUs; about 3.8 GiB RAM; 19.3 GiB disk | pass |
| `multipass exec linux-lab-01 -- sudo cloud-init status --long` after initial failure | Cloud-init completes successfully | `status: error`; package installer reported failures for `shellcheck` and `dnsutils`; schema warning also reported | fail |
| `multipass exec linux-lab-01 -- sudo cloud-init schema --system` after initial failure | Valid user-data schema | `write_files.0.permissions: 420 is not of type 'string'` | fail |
| `multipass exec linux-lab-01 -- sudo grep -n 'permissions' /var/lib/cloud/instances/linux-lab-01/cloud-config.txt` after initial failure | Guest receives permissions as a string | Guest received `permissions: 420` | fail |
| `multipass exec linux-lab-01 -- sudo journalctl -u cloud-final --no-pager -n 100` | Package repositories reachable and packages install | Connections to `ports.ubuntu.com:80` timed out; package installation failed | fail |
| `multipass exec linux-lab-01 -- getent hosts example.com` with RedShield enabled | DNS resolution works | Returned addresses for `example.com` | pass |
| `curl -I --max-time 10 http://ports.ubuntu.com/ubuntu-ports/` on the Mac with RedShield enabled | Host can reach Ubuntu repository | `HTTP/1.1 200 OK` | pass |
| Guest HTTP/HTTPS curl tests with RedShield enabled | Guest can reach Internet | Timed out | fail |
| Guest `curl -I --max-time 10 https://example.com/` after temporarily disconnecting RedShield | Determine whether VPN state affects guest connectivity | `HTTP/2 200` | pass |
| Clean `bash vm/scripts/create.sh linux-lab-01` after `permissions: !!str '0644'` fix | VM creates and baseline passes | `status: done` and `PASS: Ubuntu 24.04; architecture aarch64; systemd; baseline tools; SSH key authentication.` | pass |
| `multipass exec linux-lab-01 -- sudo cloud-init schema --system` after fix | Valid user-data schema | Valid schema for user-data, vendor-data, and network-config; vendor-data contains a deprecation warning only | pass |
| `sudo grep -n permissions .../cloud-config.txt` after fix | Permission remains a string | `permissions: '0644'` | pass |
| Restart `linux-lab-01`, then `bash vm/scripts/check.sh linux-lab-01` | Baseline survives restart | `status: done` and PASS | pass |
| Create `linux-lab-rebuild` from the same branch revision | Second clean VM reaches same baseline | Created successfully | pass |
| Initial direct `guest-check.sh` on rebuild before script fix | Guest check should pass | Exit 141 at `sshd -T | grep -q` under `pipefail` | fail |
| `guest-check.sh` after capturing `sshd -T` output before grep | Avoid SIGPIPE false negative | Both `linux-lab-01` and `linux-lab-rebuild` print PASS | pass |
| Final `multipass info` for both VMs | Same expected release/image/resources | Both Running; Ubuntu 24.04.5 LTS; image 1d6bffe64b84; 2 CPUs; about 3.8 GiB RAM; 19.3 GiB disk | pass |

## Failure and recovery

- Initial hypothesis and commands chosen by Anton:
  - Anton first identified that cloud-init appeared to have failed while installing packages.
  - He checked the VM state separately and confirmed that the VM itself was running.
  - He recognized that the package installation failure was distinct from VM creation/boot.
- Bounded fault introduced and diagnostic evidence:
  - No artificial fault was introduced. The first real VM attempt exposed two environment/configuration failures, followed by one validation-script defect.
  - Cloud-init schema validation showed that the checked-in string permission `'0644'` arrived in the guest as integer `420`.
  - Package installation failed because outbound connections from the guest timed out while RedShield VPN was enabled.
  - DNS resolution inside the guest still worked.
  - The same guest successfully reached `https://example.com/` after RedShield was temporarily disconnected.
  - After the clean rebuild, direct tracing of `guest-check.sh` showed exit 141 at the `sshd -T | grep -q` pipeline while `pipefail` was enabled.
- Cause established by evidence:
  1. Under the current macOS/QEMU/RedShield setup, RedShield interferes with outbound network connectivity from the Multipass guest. This is an environment-specific observation, not a general claim about every RedShield or Multipass configuration.
  2. Multipass/cloud-init processing did not preserve the quoted permission value as a string in the initial configuration; the guest received decimal `420`, which violated the cloud-init schema.
  3. The original SSH baseline check could produce a false failure because `grep -q` exited early and the producer received SIGPIPE; with `pipefail`, the pipeline returned 141.
- Repair, verification, and cleanup:
  - Changed the cloud-init permission to `permissions: !!str '0644'`; a fresh guest then received `permissions: '0644'` and passed schema validation.
  - No failed VM was repaired manually. The failed disposable instance was removed and recreated from repository configuration.
  - Provisioning was repeated with RedShield temporarily disconnected so the guest could reach Ubuntu package repositories.
  - Changed the SSH check to capture `sshd -T` output first and grep the captured value, avoiding the SIGPIPE false negative.
  - Both clean VMs now pass `check.sh`; `linux-lab-01` was stopped, started, and passed again.

## Recreation

- Fresh VM result: `linux-lab-01` recreated successfully from the corrected branch; cloud-init schema valid; baseline check passes before and after restart.
- Second VM result: `linux-lab-rebuild` created from the same repository configuration and passes the same baseline check.
- Second host result: not tested.
- Differences and known limits:
  - RedShield VPN currently prevents outbound TCP connectivity from the Multipass QEMU guest while DNS still resolves. Guest provisioning that needs Internet access therefore required temporarily disconnecting RedShield.
  - The lab's guest configuration and `guest-check.sh` are largely hypervisor-independent, but `create.sh` and `check.sh` are currently Multipass-specific.
  - Alternate local VM platforms have not yet been tested.

## Human demonstration

- What Anton did without a supplied solution:
  - Read the repository VM flow and explained the roles of Multipass, cloud-init, `create.sh`, `check.sh`, and `guest-check.sh`.
  - Identified the package-installation failure from cloud-init output.
  - Confirmed separately that the VM was running and that DNS resolution worked.
  - Repeated controlled connectivity tests with and without RedShield.
  - Recreated the failed VM from repository configuration, repeated the health checks, restarted it, and created the second clean VM.
- Explanation in his own words:
  - Anton identified that the VM itself had started, but cloud-init failed to install some packages. Subsequent checks separated that from the VPN-related outbound-connectivity failure. The later exit 141 was isolated to the validation script rather than the VM.
- AI assistance used:
  - ChatGPT explained the repository flow, suggested bounded diagnostic commands, interpreted the resulting evidence, prepared repository evidence, and implemented the two small configuration/check fixes after Anton's first diagnosis.
- Final acceptance:
  - Human explanation accepted.
  - PR #22 merged as commit `5c61f8213af3ebbbfdf617f2122f989b2678bbf6`.
  - Issue #1 closed.
  - `linux-lab-rebuild` stopped after the recreation proof.


## Retrospective

### Time

- Planned: **1h30m**
- Actual: **3h45m**
- Overrun: **2h15m**
- Actual / planned: **2.5x**
- T1 20-hour budget remaining after this session: **16h15m**

The estimate assumed a mostly happy-path VM bootstrap. In practice, the first run exposed three separate problems that required diagnosis: VPN/guest networking interaction, cloud-init permission type corruption, and a false-negative shell check.

### What went well

- The investigation separated failure domains instead of treating "VM failed" as one problem:
  - the VM itself booted;
  - DNS worked;
  - outbound TCP failed only with RedShield enabled;
  - cloud-init had a separate schema problem;
  - the final exit 141 came from the validation script rather than the VM.
- The failed VM was diagnosed before being replaced. No manual in-guest package repair was used to manufacture a passing result.
- The fixes were small and evidence-driven:
  - explicitly preserve `0644` as a YAML string;
  - remove the `pipefail`/SIGPIPE false negative from the SSH check.
- Reproducibility was demonstrated rather than assumed: one VM was recreated, restarted and rechecked, and a second clean VM reached the same baseline.
- The portable boundary became clearer: cloud-init plus `guest-check.sh` can be reused across compatible Ubuntu VM backends, while provisioning scripts are currently Multipass-specific.

### What did not go well

- The initial 1h30m estimate did not include a host/VPN compatibility preflight.
- Too much time was spent considering Multipass version/platform changes before the simplest A/B test isolated RedShield as the networking variable.
- The original validation script contained a pipeline that was valid-looking but brittle under `set -o pipefail`.
- Multipass works for the lab only with a current operational caveat: guest Internet access needed for provisioning fails while RedShield is enabled in this macOS/QEMU setup.

### Decisions

1. Keep the current Multipass implementation as a **working reference backend**, not yet as the assumed long-term local VM backend.
2. Do not rewrite the Linux learning core for another hypervisor. Preserve:
   - `vm/cloud-init/base.yaml`;
   - `vm/scripts/guest-check.sh`;
   - evidence and Linux exercises.
3. Treat backend-specific creation/transport as a thin adapter. If UTM, VMware Fusion, or another backend is selected, add provider-specific provisioning around the same guest baseline rather than forking the learning content.
4. Test an alternate VM backend with **RedShield left enabled** before choosing the daily driver.
5. Timebox that comparison to **60–90 minutes**. If a candidate cannot prove Ubuntu boot + guest Internet + reusable baseline within the timebox, stop and compare rather than entering another long troubleshooting session.
6. Protect the T1 parallel path: do not use this overrun as a reason to postpone the Python/Yandex model call. Cut optional Linux/course breadth before cutting the agent work.

### Next experiment

The next VM-platform experiment should answer one narrow question:

> Can a disposable Ubuntu ARM64 guest run the same baseline while RedShield remains enabled?

Minimum comparison criteria:

- works on Apple Silicon;
- guest outbound HTTP/HTTPS works with RedShield enabled;
- can consume the existing cloud-init configuration directly or with a small adapter;
- can execute the existing `guest-check.sh`;
- supports repeatable create/delete or clone/recreate workflow;
- does not require a large GUI-only manual installation procedure for every lab run.

Do not decide between UTM, VMware Fusion, or another backend based on brand preference. Use the measured result of this bounded experiment.


## Lima reproduction follow-up — 2026-10-10 (checks and explanation complete)

This is a follow-up for the daily Lima environment; the accepted Multipass result
above remains a separate observation.

- Source: base commit `e84cdb2ce6e6069c864665cffcb81af8ba6e7c44`, local branch
  `issue-1-lima-reproduction`, with uncommitted `vm/lima/baseline.yaml` and docs.
- Configuration SHA-256: `590abe484b38bb7ad6e76c14b117939599c0e857a287a14ced760fed3865897f`.
- Unchanged shared check SHA-256: `5b3a6cf7e1888193b8c1f0043629157986792442f361992a49f72feba52ff848`.
- Host: macOS ARM64, Lima 2.2.0, VZ. New instance: `linux-lab-rebuild-lima`,
  2 CPUs, 4 GiB RAM, 20 GiB disk, plain mode. Daily instance stayed running.
- Image: Ubuntu 24.04 server ARM64, release `20260926`; SHA-256
  `1d6bffe64b848468ac97f821d369a4846d983de1800ccf6b5ec8853e85cefc55`.
  Checksum verified against Ubuntu's dated release manifest before creation.
- Guest observed: Ubuntu 24.04.5 LTS, kernel `6.8.0-142-generic`.
- No repository data or provider credentials were copied into the new VM.

Codex prepared the configuration, checked it with `limactl validate`, Bash syntax
and ShellCheck, matched the ten baseline packages, then created the stopped VM.
The first ad hoc package comparison incorrectly included a `write_files` entry;
scoping that check to `packages` resolved the checker error without changing the
configuration. The older configured image URL redirected to Ubuntu's archive,
whose HTTPS checksum request timed out; the new configuration instead explicitly
selects the verified, available dated release above.

Anton ran `limactl start --timeout=15m linux-lab-rebuild-lima` from the Mac.
His terminal reached `READY`; separate inspection confirmed `Running`. This is
assisted execution from a supplied command, not an unaided recreation assessment.
Codex then verified:

- `sudo timeout 600 cloud-init status --wait`: `status: done`, **exit 2**.
- Detailed status: `degraded done`; no fatal errors; only deprecation warnings
  for Lima-generated `users.0.ssh-authorized-keys` and string-valued `users.0.uid`.
  Field names/types were inspected without publishing user identity or SSH keys.
- Streaming the unchanged `vm/scripts/guest-check.sh` into the new VM: **exit 0**,
  Ubuntu 24.04 / aarch64 / systemd / baseline tools / SSH check passed.
- Effective SSH configuration: `passwordauthentication no`, `permitrootlogin no`.

The warnings match [Lima issue #5227](https://github.com/lima-vm/lima/issues/5227)
and the [Lima 2.2.0 user-data template](https://github.com/lima-vm/lima/blob/v2.2.0/pkg/cidata/cidata.TEMPLATE.d/user-data).
[Cloud-init exit 2](https://docs.cloud-init.io/en/latest/explanation/return_codes.html)
means completion with recoverable errors. This run proves a working baseline
with a known configuration caveat, not warning-free provisioning. No in-guest
repair or warning suppression was applied.

Observed package versions:

```text
ca-certificates 20260601~24.04.1
cloud-init 26.1-0ubuntu1~24.04.1
curl 8.5.0-2ubuntu10.15
dnsutils 1:9.18.39-0ubuntu0.24.04.7
git 1:2.43.0-1ubuntu7.3
iproute2 6.1.0-1ubuntu6.4
jq 1.7.1-3ubuntu0.24.04.2
lsof 4.95.0-1build3
python3 3.12.3-0ubuntu2.1
shellcheck 0.9.0-1
ufw 0.36.2-6
```

### Restart verification and final stop

Anton ran the supplied stop/start commands on the Mac. His terminal confirmed
that the reproduction instance shut down, started again, and reached `READY`.
Codex independently verified `Running` and repeated the checks:

- `cloud-init status --wait --format json`: exit 2, `degraded done`, no fatal
  errors, and the same two generated-configuration deprecations; no new warnings.
- Unchanged shared baseline check: exit 0; Ubuntu, architecture, systemd, tools,
  and SSH checks passed again.
- Effective SSH configuration still had password authentication and root login
  disabled.

Codex stopped only `linux-lab-rebuild-lima`; the stop command exited 0. A final
inventory confirmed the reproduction VM `Stopped` and the daily VM `Running`.
The reproduction disk was retained. Both stops emitted a hostagent diagnostic
about accepting on a closed network connection during shutdown; the observed
shutdown and subsequent restart outcomes above are recorded separately.

Technical result: a fresh Lima VM reached the baseline and passed the same check
after a stop/start, with the documented cloud-init compatibility caveat.

### Human explanation and active time

Asked why a fresh VM was needed instead of only restarting the existing VM,
Anton explained that the goal was to test from scratch and check whether the
configuration was correct. This satisfies the conceptual check. Codex clarified
that restarting an existing VM can preserve earlier manual fixes.

Execution remains assisted: Codex prepared the configuration and supplied the
commands, and Anton launched and restarted the VM. This is not evidence of an
unaided recreation skill.

- Planned active time: not recorded separately for this follow-up.
- Actual active time: **15 minutes**, reported by Anton, excluding breaks.

The recreation checks, explanation, and time record are complete. The documented
cloud-init limitation remains for final T1 acceptance review. VPN state was not
observed; this run does not establish compatibility with RedShield enabled. No
second host or other architecture was tested.
