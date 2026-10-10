# Evidence: Process inspection and guided failure recovery

- Issue / PR: Related to [#4](https://github.com/anton415/linux-lab/issues/4); no PR created for this exercise.
- Dates: 2026-10-07 to 2026-10-08 (Europe/Moscow).
- linux-lab base commit: `614b9309836be6087106ae0f47ce8b0491013c6e`; at exercise time, the process fixture and documentation were uncommitted additions on `issue-4-processes-logs`.
- finance-lab commit: not applicable.
- Environment: existing Lima Linux VM accessed from macOS; host architecture, Lima version/driver, guest image/release/architecture, and tool versions were not reverified for this exercise.
- Reproduction instructions and fixture: [process lab](../labs/processes/README.md), [worker](../labs/processes/worker.sh).
- Planned time: approximately 15 minutes for the initial guided inspection step only; no separate estimate was recorded for the complete exercise.
- Actual active time: approximately **30 minutes**, reported by Anton on 2026-10-08 for the process/logs exercises across both sessions, excluding breaks.

## Observations

Codex inspected the app terminal output. The startup logs were also read directly
from the VM. Commands below use the captured exercise variables; actual process
IDs, account names, and temporary-directory identifiers are omitted.

| Command or check | Expected | Observed / exit status | Result |
|---|---|---|---|
| Start `bash labs/processes/worker.sh 600` in the background with stdout/stderr redirected, then `ps -p "$process_lab_pid" -o pid,ppid,user,stat,%cpu,rss,args` | Identify the worker and inspect resources | PID, PPID, truncated owner, and expected Bash command appeared; state `S`, CPU `0.0%`, RSS `3144 KiB` | pass |
| `cat "$process_lab_dir/stdout.log"` and `cat "$process_lab_dir/stderr.log"` | Separate normal output and diagnostics | Startup message in stdout; synthetic diagnostic message in stderr while the worker was running | pass |
| `kill -TERM "$process_lab_pid"`, `wait "$process_lab_pid"`, immediate status capture, then stdout inspection | Graceful completion | Exit `0`; `worker: stopped cleanly` | pass |
| Run `bash labs/processes/worker.sh 900` with separate failure logs and immediately capture `$?` | Reject the invalid duration | Exit `2` | pass (expected rejection) |
| `cat "$process_lab_dir/failure-stderr.log"` in a new terminal before restoring the variable | Read the saved diagnostic | Empty variable produced a root-relative filename; file not found | failed attempt |
| Restore the existing temporary-directory variable and repeat the log read | Explain the rejected input | Diagnostic required an integer from 1 to 600 seconds | pass |
| `bash labs/processes/worker.sh 1`, then `worker_status=$?` and print the saved status | Recover using a valid duration | Synthetic diagnostic, startup, and completion messages; exit `0` | pass |

RSS describes the Bash worker process, not the total memory of its child or VM.
The parent's identity was not separately checked during this exercise.

## Failure and recovery

- Initial hypothesis and commands chosen by Anton: no independent hypothesis or diagnostic command selection was recorded. When asked to diagnose the failure, Anton said he did not know; Codex supplied a hint to inspect stderr.
- Bounded fault: Codex assigned duration `900`. The worker rejected it before starting its sleep child; the observed exit status and diagnostic established invalid input.
- Additional failure: a new terminal did not retain `process_lab_dir`. The saved log still existed. Codex located it and supplied the variable-restoration command; Anton then read it successfully.
- Repair: after the range was explained, Anton proposed `600`, a valid upper bound. Codex suggested `1` for a shorter recovery check; Anton ran the supplied command and captured exit `0`.
- Cleanup: the earlier background worker reported a clean SIGTERM stop and was collected by `wait`; the recovery run completed naturally. Temporary logs were retained. Child absence after Anton's stop was not separately checked; fixture-level cleanup checks are documented in the lab README.

## Recreation

- Fresh VM result: not tested for this fixture.
- Second host result: not tested.
- Known limits: resuming in a new shell requires restoring the existing log-directory variable or starting a new exercise. Historical process IDs must not be reused for signaling.

## Human demonstration

- Anton ran the supplied process/resource inspection, separate-stream reads, graceful stop, status capture, and recovery commands.
- After guidance, he identified `600` as a valid duration. No independent full diagnosis or explanation of the process/resource fields and signal behavior was established.
- Codex prepared the fixture, provided commands and explanations, diagnosed the missing shell variable, reviewed terminal results, and wrote this evidence.
- SIGTERM cleanup versus SIGKILL was explained; forced termination was not run.
- Remaining acceptance: independent diagnosis and explanation, followed by evidence review and human acceptance. These guided results do not complete issue #4.

## T1 follow-up: HTTP startup failure and targeted stop — 2026-10-10

- Related to #4; listening-port and HTTP observations also support #8.
- Source revision: `7b6725c3756989a88f524c5f523a1162fdacbd5b`,
  branch `issue-4-t1-practical`.
- Environment: existing Lima VM; recovery response reported Python 3.12.3.
  No fresh VM or second-host reproduction was performed for this follow-up.
- Planned active time: **15 minutes**. Actual active time: approximately
  **60 minutes**, reported by Anton, excluding breaks.
- Fixture: Codex prepared a disposable directory with a synthetic web page,
  startup script and separate logs. A valid preflight served the expected page,
  then was stopped before the deliberately faulty launch.
- Public command notation below substitutes `$exercise_dir` for the actual
  temporary directory, `$previous_dir` for an earlier exercise directory and
  `$server_pid` for the freshly verified server PID. These are notation, not
  claims that Anton defined shell variables; his commands used literal paths/PIDs.

The original startup script contained:

```bash
#!/usr/bin/env bash
set -u
fixture_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec timeout --signal=TERM --kill-after=5s 1200s \
  python3 -u -m http.server --bind 127.0.0.1 \
  --directory "$fixture_dir/www" --port 18084
```

| Command or check | Observed result | Attribution |
|---|---|---|
| Initial faulty launch; saved exit status and request to `http://127.0.0.1:18084/` | Startup exit `2`; curl exit `7`, connection failed | Codex fixture setup |
| `sudo ss -ltnp` | DNS and SSH listeners present; none on port 18084 | Anton chose; Codex ran in VM |
| `ps -eo pid,ppid,user,stat,args \| grep '[h]ttp.server'` | No matching server process | Anton chose; Codex ran |
| `cat "$previous_dir/server.log"` | Historical success on ports 18083/18082, not the current target | Anton chose the previous log; Codex explained the mismatch |
| `cat "$exercise_dir/stderr.log"` | Usage ended with `[port]`; error: `unrecognized arguments: --port` | Anton requested the read after Codex supplied the current log path |
| `sed -i 's/--port 18084/18084/' "$exercise_dir/start.sh"`, then `cat "$exercise_dir/start.sh"` | Only the unsupported option was removed; port 18084 retained | Codex supplied edit; Anton reported running it; Codex verified file and `bash -n` |
| `"$exercise_dir/start.sh" > "$exercise_dir/recovery-stdout.log" 2> "$exercise_dir/recovery-stderr.log" &` | Recovery server started with a 1200-second lifetime bound | Codex supplied; Anton reported running |
| `curl --noproxy '*' -i --max-time 5 http://127.0.0.1:18084/` and `ss -ltnp 'sport = :18084'` | HTTP 200, body `Synthetic T1 Linux check OK`; Python listener on loopback port 18084 | Anton reported running curl; Codex independently verified response and listener |
| `ps -p "$server_pid" -o pid,ppid,user,stat,%cpu,rss,args` | Server PID, parent PID, truncated owner and expected Python command; state `S`, CPU `0.0%`, RSS `19180 KiB` | Codex supplied; later directly verified in VM |
| `kill -TERM "$server_pid"`, then `ss -ltnp 'sport = :18084'` | Server PID absent; no listener remained | Codex verified current PID/command first; Anton reported running the supplied stop; Codex verified process and listener absence |

### Diagnosis, explanation and assistance

- Anton selected the listener and process checks himself. No separate initial
  hypothesis was recorded before those commands.
- After reading stderr, Anton proposed switching to port 18083 or 18082.
  Codex explained that the unsupported option, rather than the number, was the
  fault and supplied the positional-port correction. When Anton asked how to
  edit the script, Codex supplied the replacement command.
- Anton later explained: "The error is about `--port`: this program doesn't
  recognize that option." This followed the explanation; it is not evidence of
  an independently discovered repair.
- Anton correctly identified PPID as the parent process ID. He explained that
  SIGTERM gives a process a chance to stop and clean up, while SIGKILL forces it
  to stop immediately.
- Initial command execution was explicitly delegated to Codex because the app
  terminal was unavailable. Anton subsequently connected to the VM and reported
  performing the guided edit, recovery and stop; Codex checked their outcomes.
- The saved startup exit status was checked by Codex. Anton's independent
  interpretation of that exit status, owner, CPU and RSS was not demonstrated.
- Observed termination proves process/listener removal after the reported SIGTERM
  command. No custom cleanup handler or exit status was verified for this Python
  HTTP server; this does not replace the earlier worker cleanup evidence.
- Only loopback synthetic resources were used. No firewall, SSH configuration,
  management route or unrelated process was changed. Temporary logs were retained.
- This follow-up adds verified recovery, targeted termination and signal
  explanation. Full unaided diagnosis remains unproven; evidence review and human
  acceptance remain pending. Issue #4 is not marked complete by this record.

### Exit-status and network-error explanation check — 2026-10-10

- Related to #4; the network-error distinctions also support #8.
- Evidence baseline: `f27592e557ceb3b5eaf3eaed1f85231c76870eef`.
- Planned time: no separate estimate recorded. Actual active time:
  **10 minutes**, reported by Anton; additional to the 60-minute practical above.
- Scope: discussion of the saved failure results and hypothetical HTTP/DNS/timeout
  cases. No new live failure or recovery was run during this explanation check.

| Topic | Anton's answer and assistance |
|---|---|
| Startup exit 2 and curl exit 7 | Initially reversed the causal order (`7 -> 2`). Codex explained that rejected server arguments caused exit 2, leaving no listener and causing curl exit 7. Anton then correctly said changing only curl would not repair the invalid server command. |
| HTTP 404 | Independently explained that the client connected and received an error response because the requested page was not found. |
| Name-resolution failure / curl exit 6 | Independently explained that the HTTP server was not reached; proposed checking hostname spelling and using `getent ahostsv4`. |
| Timeout despite a listener | Correctly rejected a firewall-only conclusion and suggested the command could take too long. Codex clarified that the server might accept the connection but respond too slowly. |
| Distinguishing connection from response delay | Anton asked which command to use. Codex supplied bounded `curl -v` syntax and explained `Trying`, `Connected to`, and HTTP response lines. Given a successful connection followed by a timeout without an HTTP response, Anton correctly selected server response handling for investigation. |

This adds explanation evidence, with guided correction for the exit-status
sequence and instruction for verbose curl diagnostics. It does not establish an
unaided end-to-end diagnosis or a live timeout investigation. Issue acceptance
remains pending; neither #4 nor #8 was closed.

## Final T1 practical: missing command and independent repair — 2026-10-10

- Related to #4; connectivity diagnosis also supports #8.
- Exercise source revision: `a1e8807e84ab580f9cd692efbc18c79825596284`.
  This record was added after PR #27 merged, on baseline
  `e02fa9268459a397407fadfd223d5f29d2a033f0`.
- Environment: existing Lima VM; HTTP response reported Python 3.12.3.
  No fresh VM, second host, or new firewall exercise.
- Planned active time: **15 minutes**. Actual active time: **30 minutes**,
  reported by Anton, excluding breaks; separate from the earlier 60 and 10 minutes.
- Codex prepared a disposable synthetic fixture, verified successful HTTP with
  the available interpreter, and stopped that preflight process. The exercise
  launcher used an unavailable command, bound only to loopback, and retained a
  1200-second timeout with a five-second forced-stop fallback.
- Anton was given the target URL, initial curl exit 7 and fixture/log locations.
  The cause and repair were not supplied before his diagnosis.

### Commands, results and ownership

The notation `$exercise_dir` and `$server_pid` below replaces the temporary path
and freshly verified PID; Anton's actual commands used literal paths and PIDs.

| Step | Command / observation | Ownership |
|---|---|---|
| First hypothesis | Nothing may be listening on port 18085 | Anton proposed before the first check |
| Listener inspection | `sudo ss -ltnp`: no listener on 18085 | Anton chose; Codex ran |
| Startup log | `cat "$exercise_dir/stderr.log"`: timeout could not run `python3-lab`, no such file or directory | Anton chose; Codex ran |
| Diagnose and inspect | Anton identified the missing command; `cat "$exercise_dir/start.sh"; command -v python3` showed `python3-lab` in the script and available `/usr/bin/python3` | Anton chose interpretation and commands; Codex ran |
| Repair | `sed -i 's/python3-lab/python3/' "$exercise_dir/start.sh"` | Anton proposed exact repair; Codex applied it and verified the saved script with `cat` and `bash -n` |
| Start | `cd "$exercise_dir"; ./start.sh >recovery-stdout.log 2>recovery-stderr.log &` | Anton chose; Codex ran, guarded failed directory changes and saved the launcher PID |
| Verify HTTP | `curl --noproxy '*' -i --max-time 5 http://127.0.0.1:18085/`: HTTP 200, `Synthetic T1 final check OK`, exit 0 | Anton chose; Codex ran |
| Inspect processes | `ps -eo pid,ppid,user,stat,%cpu,rss,args \| grep '[h]ttp.server'`: timeout parent and Python child visible | Anton chose; Codex ran |
| Interpret resources | Correctly selected Python child PID, timeout parent PID, CPU `0.1%` and RSS `19176 KiB` | Anton interpreted the displayed output correctly |
| Show full owner | `ps -p "$server_pid" -o pid,ppid,user:32,args`: full owner shown, matching the original VM account | Anton requested help with column width, then explicitly requested execution of the supplied command |
| Targeted stop | `kill -TERM "$server_pid"`, then `ss -ltnp 'sport = :18085'`: no listener row | Anton chose; Codex verified exact process arguments before sending SIGTERM and ran the listener check |
| Saved startup status | `cat "$exercise_dir/exit-status.txt"`: `127` | Codex supplied the read command after a repeated owner-formatting question; Anton reported `127` |
| Final cleanup verification | No listener on 18085 and original Python server PID absent | Codex verified before writing evidence |

### Learning outcome and limits

- Anton independently chose the initial hypothesis, diagnostic sequence, repair,
  HTTP verification, process inspection and targeted termination commands.
  Codex executed those commands at his direction; this is human-led diagnosis
  with delegated execution, not a claim that Anton typed every command in the VM.
- The diagnosis connected the missing executable to failed startup and the absent
  listener. After repair, the original target returned a successful HTTP response.
- Anton independently interpreted PID, PPID, CPU and RSS. Assistance was limited
  to widening the owner column, reading the saved exit-status file, and explaining
  exit 127's meaning. His later cause/repair explanation matched his earlier
  independent diagnosis and exact proposed replacement.
- The server's owner was displayed in full but is omitted here for public privacy.
  The exact temporary identifier and process IDs are likewise omitted.
- No broad kill, SSH change, firewall change or public listener was used.
  The verified Python process was stopped; temporary files/logs were retained.
  Its termination exit status and custom cleanup behavior were not measured.
- This practical supplies the previously missing human-led diagnosis and repair
  evidence for review. Earlier guided attempts remain accurately recorded.
  Final human acceptance of #4 and #8 remains pending; no issue is closed here.
