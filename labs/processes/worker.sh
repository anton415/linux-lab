#!/usr/bin/env bash

duration="${1:-600}"
if (( $# > 1 )) || [[ ! "$duration" =~ ^[1-9][0-9]{0,2}$ ]] || (( duration > 600 )); then
    printf 'worker: duration must be an integer from 1 to 600 seconds\n' >&2
    exit 2
fi

child_pid=""

stop_worker() {
    trap '' TERM INT
    if [[ -n "$child_pid" ]]; then
        kill -TERM "$child_pid" 2>/dev/null || true
        wait "$child_pid" 2>/dev/null || true
    fi
    printf 'worker: stopped cleanly\n'
    exit 0
}

# Defer an early stop until the newly started child's PID is available.
stop_requested=0
trap 'stop_requested=1' TERM INT
sleep "$duration" &
child_pid=$!
trap stop_worker TERM INT
if (( stop_requested )); then
    stop_worker
fi

printf 'worker: synthetic diagnostic message\n' >&2
printf 'worker: started for %s seconds\n' "$duration"
if wait "$child_pid"; then
    child_pid=""
    printf 'worker: completed\n'
else
    result=$?
    child_pid=""
    printf 'worker: child exited with status %s\n' "$result" >&2
    exit "$result"
fi
