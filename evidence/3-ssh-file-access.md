# Evidence: #3 SSH login and file-access repair

- Issue: https://github.com/anton415/linux-lab/issues/3
- Date: 2026-10-06.
- Base linux-lab commit: `e84cdb2ce6e6069c864665cffcb81af8ba6e7c44`; this record captures the subsequent practice.
- Environment: existing Lima VM `linux-lab-lima`, with a separate Mac terminal and Linux sessions. This is not a new VM recreation test.
- Time: additional time for this follow-up was not recorded yet. The earlier one-hour estimate in the [Day 3 record](3-day3-linux-practice.md) covers the preceding exercises only.
- Privacy: synthetic account and file names only; key material, fingerprints, real account names, client addresses, and raw authentication logs are omitted.

## Account and key setup

Anton ran the supplied account-creation command inside the VM:

```bash
sudo adduser --disabled-password --comment "" labuser
id labuser
```

The reported and independently inspected identity had UID/GID 1001, primary group `labuser`, and supplementary group `users`. The group listing does not by itself establish the entire sudo policy. Anton used `sudo -iu labuser`, then showed `whoami` returning `labuser` and `pwd` returning `/home/labuser`.

Anton created `/home/labuser/.ssh` with mode `700`. On the Mac he generated a dedicated Ed25519 key using:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/linux-lab-labuser -C "linux-lab-practice"
```

The private key remained outside the repository on the Mac. Codex inspected only public-key metadata. The public key was installed through the existing Lima management account:

```bash
cat ~/.ssh/linux-lab-labuser.pub |
  limactl shell linux-lab-lima \
    sudo -u labuser \
    tee -a /home/labuser/.ssh/authorized_keys > /dev/null

limactl shell linux-lab-lima \
  sudo -u labuser chmod 600 /home/labuser/.ssh/authorized_keys
```

Codex verified directory mode `700`, file mode `600`, ownership by `labuser`, and a matching public-key fingerprint on the Mac and in the VM.

Anton then used `ssh` from the Mac with `IdentitiesOnly=yes`, `ControlPath=none`, the dedicated identity file, the VM's current forwarded SSH port, and user `labuser`. The runtime port was read from Lima rather than treated as a stable setting. Codex supplied a verified VM host-key fingerprint for comparison. The screenshot showed `whoami` returning `labuser` and `pwd` returning `/home/labuser`. Codex independently found an accepted public-key authentication event for `labuser` matching the practice key, printing only a sanitized confirmation.

## File-access observations

Codex prepared `/tmp/linux-lab-access-labuser/note.txt`, containing only `Synthetic Linux permissions exercise.` and a newline. The directory was owned by `labuser` with mode `755`; the file was owned by `labuser` with mode `600`.

| Check | Actual observation | Attribution |
|---|---|---|
| `cat /tmp/linux-lab-access-labuser/note.txt` in the `labuser` session | Synthetic message printed | Anton supplied a screenshot |
| `limactl shell linux-lab-lima cat /tmp/linux-lab-access-labuser/note.txt` from the Mac | `Permission denied` | Anton supplied a screenshot; this command ran as the original VM account without sudo |
| `ls -l /tmp/linux-lab-access-labuser/note.txt` | `-rw-------`, owned by `labuser:labuser` | Anton selected `ls -l` after being asked to inspect ownership and permissions |
| `chmod go+r /tmp/linux-lab-access-labuser/note.txt` as `labuser` | Final mode `-rw-r--r--` | Anton supplied the exact repair command and final mode |
| Repeat the read as the original VM account, without sudo | Synthetic message printed | Anton reported the result; Codex independently verified mode `644`, a successful read, and a non-root reader different from the file owner |

## Failures and recovery

An initial key-installation command was split after `sudo -u labuser`, leaving sudo without a command. The subsequent `tee` ran on the Mac and could not find the guest path. After a prompt-based hint, Anton identified the Mac as the location of that failed `tee`. He reran the complete supplied command and confirmed completion.

During access diagnosis, Anton tried `sudo limactl ...` on the Mac. Lima rejected execution as root. Codex explained that this elevated the host command, not the command inside the VM.

For the file denial, Anton interpreted the owner-only read/write mode correctly. He initially proposed `chmod go+rwx filename`; Codex pointed out that group/other write and execute permissions exceeded the requested access. Anton ultimately reported using `go+r`; with the existing mode `600`, this produced `644`. The repair granted read access while leaving ordinary-user write access with the owner. No world-writable mode was observed or required.

## Human evidence and limits

Account creation, key installation, and SSH login were guided. Anton performed the commands, selected the file inspection command, and identified owner-only access. The repair followed a hint about avoiding write/execute grants, so this is recorded as a guided diagnosis and repair, not an independently completed assessment.

Anton decided that one completed access-denial case was sufficient for this session and declined the additional repeat to prioritize other T1 work. The repeat was not performed and is not queued as another exercise. This record preserves the guided nature of the completed repair; it does not claim an independent assessment.

Codex had prepared the extra case by changing only the synthetic directory from mode `755` to `700`. After Anton declined it, Codex restored `755`, preserved the repaired file at `644`, and verified that the original non-root VM account could read it again. The synthetic fixture remains in that working state.

Additional follow-up time is not recorded. Fresh-VM and second-host reproduction were not tested. Full issue #3 acceptance, including its independent-repeat criterion, is not established by this evidence; the issue remains open and no GitHub state was changed.
