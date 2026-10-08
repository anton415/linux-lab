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
