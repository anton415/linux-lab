# Recreate the lab VM

## Baseline decision

Use Ubuntu Server 24.04 LTS with Multipass and cloud-init. A supported release is
chosen deliberately; it is not a claim to use the newest Ubuntu. Multipass supplies
the VM and initial key access; cloud-init supplies the guest packages/configuration.
The learning core starts after this baseline.

Install Multipass using the [official host instructions](https://canonical.com/multipass/docs/latest/how-to-guides/install-multipass/).
Use Bash on macOS/Linux. Windows users need a compatible Bash environment and must
validate host integration separately. On another architecture use its native guest
image and record the difference. Cross-architecture behavior has not been verified.

The seed was authored on macOS ARM64 without Multipass installed. Shell checks can
be performed there; **VM boot and cloud-init execution remain unverified until L1.1**.

## Create and check

From the repository root:

```bash
multipass version
bash vm/scripts/create.sh linux-lab-01
bash vm/scripts/check.sh linux-lab-01
multipass shell linux-lab-01
```

Creation downloads Ubuntu, updates the package index, installs baseline tools, and
checks cloud-init, OS, systemd, packages, and SSH password authentication. It needs
network access. An existing name causes launch to fail; use `check.sh` to inspect
an existing running instance. A changed cloud-init file applies to a new instance,
not retroactively to an old one.

No host directories are mounted. Multipass's default networking is used; do not
assume it is an isolated security boundary. Keep exercises local, use synthetic
data, and inspect listening addresses before opening a service. UFW is installed
but **not enabled** in the baseline; access rules are a later exercise.

## Prove recreation

Create a second instance from the same commit instead of deleting the first:

```bash
bash vm/scripts/create.sh linux-lab-rebuild
bash vm/scripts/check.sh linux-lab-rebuild
multipass stop linux-lab-rebuild
```

For each run record the linux-lab commit, Multipass version/driver, guest
architecture, cloud image identifier, package versions, and actual check results.
`multipass info --format json linux-lab-01` helps identify the image; review its
output before publishing because it can include addresses or mounts. In the guest,
inspect `/etc/os-release`, `uname -r`, and `dpkg-query -W` for relevant packages.

The `24.04` alias and package repositories change over time. This recreates the
configuration and intended behavior, not a byte-identical disk or frozen package
set. Keep the observed image ID and package versions in evidence. A later task can
pin a verified image when an experiment requires stronger repeatability; never
invent an image checksum. A second host remains unverified until actually tested.

## Stop, restart, and remove

```bash
multipass stop linux-lab-01
multipass start linux-lab-01
bash vm/scripts/check.sh linux-lab-01
```

Only after saving reviewed evidence, the human may deliberately remove a named
disposable VM with `multipass delete linux-lab-rebuild`. It is recoverable with
`multipass recover linux-lab-rebuild` until purged. `multipass delete --purge
linux-lab-rebuild` permanently removes that VM and its data. No script runs deletion;
never use a global purge for this exercise.

## Diagnose a failed setup

Run `multipass list` and `multipass info linux-lab-01` first. If the VM is running:

```bash
multipass exec linux-lab-01 -- sudo cloud-init status --long
multipass exec linux-lab-01 -- sudo journalctl -u cloud-final --no-pager -n 60
multipass exec linux-lab-01 -- sudo cloud-init schema --system
```

Read logs locally. Do not publish raw logs or shell history. A timeout or cloud-init
warning is not a passed check; record it, diagnose network/package/schema problems,
and keep the failed instance available while investigating.

## Validate changes

```bash
for script in vm/scripts/*.sh; do bash -n "$script"; done
shellcheck vm/scripts/*.sh
```

If ShellCheck is only installed in the guest, transfer these scripts into a guest
scratch directory and run it there. Validate the YAML with cloud-init's schema in
an Ubuntu environment, then create a fresh VM. Syntax-only results must stay
distinct from completed provisioning/reboot/rebuild results.

References: [Multipass and cloud-init](https://canonical.com/multipass/docs/stable/how-to-guides/manage-instances/launch-customized-instances-with-multipass-and-cloud-init/),
[executing guest commands](https://canonical.com/multipass/docs/latest/reference/command-line-interface/exec/),
[cloud-config validation](https://docs.cloud-init.io/en/latest/howto/debug_user_data.html),
[VM deletion semantics](https://canonical.com/multipass/docs/latest/reference/command-line-interface/delete/).


## Lima follow-up on Apple Silicon

The daily lab uses Lima. The accepted Multipass result is recorded in
[evidence/1-vm-baseline.md](../evidence/1-vm-baseline.md); the instructions above
remain the Multipass path. The Lima follow-up uses the same packages, baseline
marker, and unchanged `vm/scripts/guest-check.sh`.

`vm/lima/baseline.yaml` targets Lima 2.2.0 on macOS ARM64 with VZ, 2 CPUs, 4 GiB
RAM, and a 20 GiB disk. Plain mode disables mounts and the container runtime;
Lima still provides SSH access and runs system provisioning. No repository data
or provider credentials are copied into the guest. UFW is installed, not enabled.

The configuration selects the dated Ubuntu 24.04 ARM64 server image from
2026-09-26 and its published SHA-256 checksum. This is a new baseline run, not a
copy of the current VM disk. Package repositories are not frozen, so installed
package versions can differ. Other architectures and a second Mac are unverified.

Run these commands **on the Mac**, from a checkout containing this configuration.
Creation must succeed before starting; an existing name is not a fresh recreation.
Keep the daily `linux-lab-lima` VM intact.

```bash
limactl version
limactl validate vm/lima/baseline.yaml
limactl create --tty=false --name=linux-lab-rebuild-lima vm/lima/baseline.yaml
limactl start --timeout=15m linux-lab-rebuild-lima
limactl shell linux-lab-rebuild-lima sudo timeout 600 cloud-init status --wait
limactl shell linux-lab-rebuild-lima bash -s < vm/scripts/guest-check.sh
```

After recording successful provisioning and baseline checks, stop, start, and
check only the reproduction instance:

```bash
limactl stop linux-lab-rebuild-lima
limactl start --timeout=15m linux-lab-rebuild-lima
limactl shell linux-lab-rebuild-lima sudo timeout 600 cloud-init status --wait
limactl shell linux-lab-rebuild-lima bash -s < vm/scripts/guest-check.sh
limactl stop linux-lab-rebuild-lima
```

Record source revision (and any uncommitted configuration), Lima version/backend,
image checksum, guest/package versions, actual check results, VPN state, assistance,
and active time. A successful syntax check or `Running` state alone does not prove
reproduction. The first Lima boot passed the shared baseline check on 2026-10-10; cloud-init
completed with the deprecation warnings described below. The stop/start check
also passed on 2026-10-10 with the same warnings. The reproduction VM was then
stopped; its disk remains available. No deletion is part of these commands.

With Lima 2.2.0 and cloud-init 26.1, the observed `cloud-init status --wait` exit
was 2 (`degraded done`). Inspection found no fatal errors and only two deprecated
fields in Lima-generated user data: `ssh-authorized-keys` and a string-valued
`uid`. These match [Lima issue #5227](https://github.com/lima-vm/lima/issues/5227).
Inspect `cloud-init status --long --format json` on each run: exit 2 is not
a blanket success. Record the actual warnings separately from the baseline
result; do not clear status files or edit the running guest to manufacture a clean
first-boot result. See [the follow-up evidence](../evidence/1-vm-baseline.md).

If setup fails, preserve the instance and inspect its local logs:

```bash
limactl list
limactl shell linux-lab-rebuild-lima sudo cloud-init status --long
limactl shell linux-lab-rebuild-lima sudo journalctl -u cloud-final --no-pager -n 60
```

Review logs before publishing evidence. If a dated image later moves to Ubuntu's
archive, verify its new official location and checksum; do not silently substitute
an unverified image or remove checksum validation.

References: [Lima plain mode](https://lima-vm.io/docs/config/plain/),
[Ubuntu image checksums](https://cloud-images.ubuntu.com/releases/noble/release-20260926/SHA256SUMS).
