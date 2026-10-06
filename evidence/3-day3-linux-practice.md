# Evidence: Day 3 Linux practice

- Related issue: [#3 — users, SSH, and permissions](https://github.com/anton415/linux-lab/issues/3).
- Process practice is preparatory work for [#4](https://github.com/anton415/linux-lab/issues/4); neither issue is complete.
- Date: 2026-10-06.
- Base linux-lab commit: `e84cdb2ce6e6069c864665cffcb81af8ba6e7c44`.
- Environment: existing Lima Linux VM. Full baseline, image identifier, and tool versions were not reverified.
- Planned Day 3 time: 1 h 15 min. Actual active time: approximately 1 hour, reported by Anton, excluding breaks and covering all exercises below.
- Permission fixture and recovery: [instructions](../labs/access/README.md) and [detailed evidence](3-file-execute-permission.md).

## Observations

| Exercise | Observed result | Evidence source |
|---|---|---|
| Directly execute the permission fixture before and after adding owner execute permission | Initial permission denial; final mode `-rwxr--r--` and successful execution | Initial failure reported by Anton; final state and exit 0 independently verified by Codex |
| `sleep 600 &`, `jobs -l`, and `ps -p <pid> -o pid,ppid,user,stat,comm` | Background sleep process identified; parent was the shell; state `S` | Anton supplied PID, PPID, and state; Codex independently inspected the process and parent |
| `kill -TERM <pid>` followed by `ps` | Process no longer appeared | Anton reported the result after following supplied commands |
| Repeat with a new background `sleep 300` process, inspect it, terminate it, and check again | Anton reported completion and the PID; subsequent `ps` returned only its header, exit 1 | Repeat was assigned without supplying the commands again; Codex verified the final absence only |
| `systemctl status ssh --no-pager` | `active (running)` | Anton reported the status line |
| `journalctl -u ssh -n 10 --no-pager` | No journal files opened due to insufficient permissions | Anton supplied a screenshot and identified a permission problem |
| `sudo journalctl -u ssh -n 10 --no-pager` | A log entry recorded accepted public-key authentication, with client address and port | Anton described the result; privileged logs were not independently fetched by Codex |
| `id` | Only the account's primary group appeared; neither `adm` nor `systemd-journal` was present | Screenshot supplied by Anton |

Actual process IDs, account names, client addresses, ports, and raw authentication logs are omitted. `<pid>` denotes the particular exercise process, not a fixed PID to reuse.

## Repeat the process and log checks

Run in the lab VM. Capture the PID of the process just started; never reuse a historical PID from a previous session.

```bash
sleep 300 &
lab_pid=$!
jobs -l
ps -p "$lab_pid" -o pid,ppid,user,stat,comm
kill -TERM "$lab_pid"
ps -p "$lab_pid" -o pid,stat,comm
```

After termination has completed, the final `ps` should show only its header and return 1. If termination is still pending, repeat the inspection. This expected absence is the cleanup check.

```bash
systemctl status ssh --no-pager
journalctl -u ssh -n 10 --no-pager
id
sudo journalctl -u ssh -n 10 --no-pager
```

Journal visibility depends on the account's access. The privileged read requires sudo authorization. These commands inspect the service and logs; the exercise did not restart SSH or change account groups or journal permissions.

## Failure, recovery, and learning

The file execution failure was repaired by granting execute permission to the owner. The journal access failure was resolved for the diagnostic command by using sudo. No journal file modes or group memberships were changed.

Anton correctly identified the journal failure as a permission problem and recognized a successful public-key authentication entry. Codex explained PID/PPID, sleeping state, service status versus log history, and the difference between persistent file permissions and elevated execution of a command.

Anton initially described `chmod u+x` as granting execution to everyone. After correction, he answered that another ordinary user would need sudo for direct execution of this fixture. Codex clarified that sudo must be authorized: `u` means the file owner, and this fixture's owner already has execute permission. This was a guided understanding check.

## Limits and remaining work

Day 3's guided practice is recorded; independent competence and full issue acceptance are not established by these exercises. Codex prepared the permission fixture and this record, supplied most commands, and performed the independent checks explicitly marked above. The repeated process exercise was self-reported; its command sequence was not observed.

Subsequent dedicated-user creation, key login, allowed versus unrelated-user denied access, and guided repair are recorded in the [SSH and file-access follow-up](3-ssh-file-access.md). Those later exercises are outside the one-hour estimate above. Anton chose to finish access-denial practice after one guided file-access case; the additional independent repeat was skipped at his request. See the linked follow-up for the limits of the evidence.

For issue #4, this record covers only introductory process inspection and signals. Its dependency on #3 remains; package work, stdout/stderr, resource inspection, and the full failure/diagnosis exercise were not completed here.

Fresh-VM recreation and a second-host run were not tested. Full issue acceptance is not claimed here; GitHub issue state was not changed.
