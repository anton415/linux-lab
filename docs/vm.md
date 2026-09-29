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
