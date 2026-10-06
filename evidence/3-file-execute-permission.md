# Evidence: #3 file execution permission drill

- Issue: https://github.com/anton415/linux-lab/issues/3
- Date: 2026-10-06
- Base linux-lab commit: e84cdb2ce6e6069c864665cffcb81af8ba6e7c44
- Environment: existing Lima Linux VM; fixture stored on the guest filesystem.
- VM image identifier and full baseline: not reverified for this exercise.
- Planned / actual time for this exercise: not recorded.
- Reproduction: [permission drill](../labs/access/README.md).

## Observations

| Command or check | Observed result | Evidence |
|---|---|---|
| `bash -n labs/access/hello.sh` | Exit 0 | Codex verified before the exercise |
| Initial `ls -l labs/access/hello.sh` | `-rw-r--r--`; current user owns the file | Codex inspected directly |
| Initial `./labs/access/hello.sh` | `Permission denied`; exit status not captured | Anton reported the error |
| `chmod u+x labs/access/hello.sh` | Anton reported completion of the supplied steps | Guided human action |
| Final `ls -l labs/access/hello.sh` | `-rwxr--r--` | Codex independently verified |
| Final `./labs/access/hello.sh` | `Hello from the Linux permissions lab.`; exit 0 | Codex independently verified |

## Failure and recovery

The fixture initially lacked execute permission. Adding `u+x` granted it to the owner while preserving the group and other permissions. The drill changes only its own harmless fixture and can be repeated by restoring mode `644`.

## Human demonstration

Anton reported the failure and identified the missing `x` after an explanation of `r`, `w`, and `x`. He then followed the supplied repair commands. Codex prepared the script, supplied the diagnostic and repair commands, and checked the resulting state.

This is a completed guided exercise, not an independent diagnosis demonstration. Fresh-VM recreation and a second-host run were not tested. Later dedicated-user creation, key login, cross-user denial, and guided repair are recorded in the [SSH and file-access evidence](3-ssh-file-access.md). Anton chose to stop after the completed guided file-access case; the additional independent repeat was skipped at his request. The linked record states the remaining limits of the evidence; issue #3 remains open. Later inspection of the existing SSH service and logs, the corrected explanation of `u+x`, and the combined one-hour practice time are recorded in the [Day 3 evidence](3-day3-linux-practice.md).
