# Blocked connection with a listening server

Related to [issue #8](https://github.com/anton415/linux-lab/issues/8).
This local VM exercise contrasts an absent listener with traffic dropped before
a TCP connection reaches a listening HTTP server. See the
[observed results](../../evidence/8-blocked-connection.md).

## Scope and prerequisites

Use the existing Linux VM, Python 3, GNU timeout, iptables, curl, ss, and sudo.
Keep a working SSH management connection. This exercise affects only IPv4 TCP
traffic arriving on loopback for `127.0.0.1:18081`; it does not change policies
or SSH port 22. The server has a 20-minute limit.

The [firewall helper](firewall-lease.py) inserts one uniquely commented DROP rule.
It removes that exact rule on normal completion or handled termination, and
starts a separate timed cleanup process before applying the rule. The helper
accepts a lifetime of 1–900 seconds. It is an educational fixture, not a general
firewall manager; use it only in this disposable lab.

## First VM terminal: prepare the server

From the repository root, inspect the current listener and firewall state:

```bash
ss -H -ltn 'sport = :18081'
sudo iptables -S
```

Continue only if port 18081 is free and you understand the current rules. Save
the original state for comparison; do not flush or replace it during cleanup.

```bash
fixture_dir=$(mktemp -d /tmp/blocked-http-XXXXXX)
cp labs/networking/firewall-lease.py "$fixture_dir/firewall-lease.py"
printf 'Synthetic blocked-path HTTP lab: OK\n' >"$fixture_dir/index.html"
sudo iptables -S >"$fixture_dir/firewall-before.txt"
timeout --signal=TERM --kill-after=5s 1200s \
  python3 -u -m http.server 18081 --bind 127.0.0.1 --directory "$fixture_dir" \
  >"$fixture_dir/server.log" 2>&1 &
blocked_http_pid=$!
```

Wait for the startup message in the server log, then verify a working baseline:

```bash
cat "$fixture_dir/server.log"
curl --noproxy '*' -f -i --connect-timeout 3 --max-time 5 http://127.0.0.1:18081/
```

Require HTTP 200 and the synthetic body before applying the temporary block.
Run the helper in the foreground for five minutes:

```bash
sudo python3 -u "$fixture_dir/firewall-lease.py" 300
```

Wait for its `temporary_rule_active` message. It prints the helper and watchdog
PIDs and saves their metadata inside the temporary directory. Keep this terminal
open. For early removal, send SIGTERM only to the current, verified helper PID;
check that its command points to this fixture's `firewall-lease.py` first.

## Second VM terminal: observe the failure and recovery

Use another VM shell. Confirm the management connection still works, then run:

```bash
curl --noproxy '*' -f -i --connect-timeout 3 --max-time 5 http://127.0.0.1:18081/
http_lab_status=$?
printf 'Exit status: %s\n' "$http_lab_status"
ss -ltnp 'sport = :18081'
```

Expected: connection timeout around three seconds, curl exit 28, and a listening
Python server. In this controlled case the rule establishes the cause. A timeout
alone does not prove a firewall fault; curl can also time out at other stages.

After the helper removes the rule, repeat the same curl/status commands. Expect
HTTP 200 and exit 0 without restarting the server.

## Cleanup

In the first VM terminal, compare `sudo iptables -S` with the saved baseline.
If cleanup reports an error, inspect the exact tagged rule and helper state;
never flush chains or delete unrelated rules.

Inspect `ps -p "$blocked_http_pid" -o pid,user,args` before signaling the timeout
wrapper. If it is still this exercise's wrapper, stop it with
`kill -TERM "$blocked_http_pid"` and collect it with `wait "$blocked_http_pid"`.
If it already exited, skip kill; never reuse a historical PID.

Confirm no listener remains with `ss -H -ltn 'sport = :18081'`.
Synthetic temporary files are retained for inspection and must not be committed.
