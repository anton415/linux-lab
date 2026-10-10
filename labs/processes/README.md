# Process inspection lab

Related to [issue #4](https://github.com/anton415/linux-lab/issues/4).
This fixture supports process inspection, output streams, exit-status diagnosis,
and graceful termination. The guided exercise is complete; independent diagnosis
and evidence review remain. See the [exercise record](../../evidence/4-processes-logs.md).

## Prerequisites and scope

Run inside the existing Linux lab VM, from the repository root, using Bash, sleep,
and ps. No sudo or service changes are needed. The worker prints synthetic messages
and waits through one child process. It uses little CPU and stops automatically
after the requested duration (1–600 seconds; default 600).

The first guided inspection step was planned for approximately 15 minutes.
Anton reported approximately 30 minutes of active time for the process/logs
exercises across both sessions, excluding breaks. No separate total estimate
was recorded.

## Start and inspect

Keep these commands in the same Bash session so the captured PID and log directory
remain available. Create a new temporary directory for each run:

```bash
process_lab_dir=$(mktemp -d /tmp/linux-lab-processes.XXXXXX)
bash labs/processes/worker.sh 600 >"$process_lab_dir/stdout.log" 2>"$process_lab_dir/stderr.log" &
process_lab_pid=$!
ps -p "$process_lab_pid" -o pid,ppid,user,stat,%cpu,rss,args
```

`%CPU` reports processor use; `RSS` is resident memory in KiB.
The worker mostly waits, so low CPU use is expected. Inspect the separate streams:

```bash
cat "$process_lab_dir/stdout.log"
cat "$process_lab_dir/stderr.log"
```

Stderr can contain diagnostic messages even when a program is healthy.
Use the exit status and surrounding observations when assessing failure.

## Stop and inspect completion

Within ten minutes of starting it, inspect the saved PID and command before
signaling the same background job. Do not reuse a PID from an older session:

```bash
ps -p "$process_lab_pid" -o pid,ppid,user,args
kill -TERM "$process_lab_pid"
wait "$process_lab_pid"
process_lab_status=$?
printf 'Worker exit status: %s\n' "$process_lab_status"
cat "$process_lab_dir/stdout.log"
```

If the worker has already completed, skip kill and use wait to collect its status.
SIGTERM is handled by stopping and reaping the worker's own child, then exiting
with status 0. Forced termination does not run this cleanup handler.
Logs remain only in the printed temporary-directory location for inspection:

```bash
printf 'Exercise logs: %s\n' "$process_lab_dir"
```

## Diagnosis exercise

Before using the worked example below for an independent check, record a first
hypothesis and choose diagnostic commands. The completed attempt was guided; see
the [observations and learning limits](../../evidence/4-processes-logs.md).

From the repository root in the same Bash session, reject an out-of-range duration
and save its exit status immediately:

```bash
bash labs/processes/worker.sh 900 >"$process_lab_dir/failure-stdout.log" 2>"$process_lab_dir/failure-stderr.log"
process_lab_failure_status=$?
printf 'Exit status: %s\n' "$process_lab_failure_status"
cat "$process_lab_dir/failure-stdout.log"
cat "$process_lab_dir/failure-stderr.log"
```

Expected: exit 2, empty stdout, and a diagnostic requiring an integer from 1 to
600 seconds. This input is rejected before the sleep child starts. Recover with
a short valid duration:

```bash
bash labs/processes/worker.sh 1
worker_status=$?
printf 'Exit status: %s\n' "$worker_status"
```

Expected: completion and exit 0, even though the synthetic diagnostic is still
printed to stderr. In a new terminal, shell variables are not retained. Restore
the saved directory location before reading old logs, or repeat the start step
to create a new exercise; do not reuse an old process ID.

Do not commit raw terminal history or unsanitized process output.

## Fixture verification

Codex checked Bash syntax and ShellCheck, normal completion with separate stdout
and stderr, five rejected input cases, and three stops immediately after startup.
Each stop returned status 0 and left no worker child running.

An initial stop check timed out. Review found that the startup message preceded
child-PID capture. Startup now captures the child PID before reporting readiness,
and defers early stop signals until cleanup can address that child. The corrected
checks passed; the short-lived diagnostic and verification processes were cleaned up.

These checks verify the AI-prepared fixture. They do not demonstrate Anton's
independent process diagnosis or satisfy the remaining human acceptance criteria.
