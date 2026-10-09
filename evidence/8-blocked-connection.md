# Evidence: Listening server behind a temporary packet drop

- Issue / PR: Related to [#8](https://github.com/anton415/linux-lab/issues/8); guided follow-up.
- Date: 2026-10-09 (Europe/Moscow).
- Base revision: `21e04e58261d2064a693910a32a3a1a61a093cb7`, branch `issue-8-host-http`.
- Environment: existing Lima Linux VM, Python 3.12.3 from the observed HTTP response. Guest image and other package versions were not reverified.
- Instructions and fixture: [blocked-connection guide](../labs/networking/blocked-connection.md), [temporary-rule helper](../labs/networking/firewall-lease.py).
- Helper SHA-256: `57c33fbeac3cd11399e698b21d512ece77e6323abe0d845432f83634f0615a02`; copied unchanged from the temporary fixture used for this exercise.
- Planned human step: approximately 5 minutes.
- Actual active time: not yet reported; requested separately from previous sessions.

## Preparation and observations

Codex prepared the synthetic HTTP server, temporary rule, and cleanup processes.
The server bound only to VM loopback port 18081 and had a 20-minute limit. The
rule matched only loopback IPv4 TCP traffic destined for that address and port.
SSH port 22 and the firewall policies were not changed. Machine account names,
process IDs, and temporary-directory identifiers are omitted.

| Check or action | Observed result | Evidence source |
|---|---|---|
| Inspect listeners and `sudo iptables -S` before setup | Exercise port free; no rules in the inspected IPv4 filter table; INPUT, FORWARD, and OUTPUT policies ACCEPT | Codex read-only checks |
| Start the synthetic server and request its root URL | HTTP 200 and `Synthetic blocked-path HTTP lab: OK` | Codex setup check |
| Apply a five-second test lease; curl with one-second connection limit; inspect listener | Curl exit 28 while the server remained listening | Codex fixture verification |
| Wait for the test lease to finish; compare firewall state and retry HTTP | Helper exited 0; original filter state restored exactly; HTTP 200 recovered | Codex automatic rollback verification |
| Enable the 900-second exercise lease with a separate cleanup timer | Helper reported the temporary rule active | Codex setup |
| Make a fresh SSH connection while the block was active | Management connection succeeded; server still listening | Codex independent SSH check |
| Enter a bare HTTP URL at the VM Bash prompt | Bash treated it as a command/path and reported file not found | Anton's terminal, read by Codex |
| Make the VM curl request to `http://127.0.0.1:18081/` | Connection timeout after 3006 ms; curl error 28 | Anton's terminal, read by Codex |
| Save `http_lab_status=$?`, print it, then `ss -ltnp 'sport = :18081'` | Exit status 28; Python socket in LISTEN state at the target | Anton's terminal, read by Codex |
| Verify and stop the specific lease helper with SIGTERM | Exact temporary rule removed; helper and watchdog exited; original filter state restored; same Python server still listening | Codex cleanup of the fault |
| Retry `curl --noproxy '*' -f -i --connect-timeout 3 --max-time 5 http://127.0.0.1:18081/` and immediately save/print status | HTTP/1.0 200 OK, synthetic body, exit 0 | Anton's terminal, read by Codex |
| Stop the verified exercise server; check its timeout wrapper, helper processes, listener, and filter state | Server and wrapper gone; helper/watchdog absent; no listener on 18081; original firewall state preserved | Codex final cleanup |

Synthetic temporary files were retained. No broad process termination, firewall
flush, default-policy change, VM network change, or public listener was used.

## Failure and recovery

- First hypothesis: the packet-drop cause was disclosed in advance as a guided demonstration; no independent discovery of the fault is claimed.
- Anton reported "Timeout was reached", then confirmed the listener as "LISTEN", and reported exit 0 after the retry.
- Cause: the process had a listening socket, but the controlled DROP rule prevented the TCP connection. The observed error was a connection timeout, not an HTTP error response or a post-connection response timeout.
- Repair: Codex removed only the exact temporary rule by stopping its verified helper. The server was not restarted. Anton's subsequent successful request demonstrates recovery after restoring traffic.
- Assistance: Codex prepared and verified the fixture, explained the contrast with exit 7, supplied the listener/status commands and recovery command, removed the fault, and performed final cleanup.

## Verification and limits

- The saved helper is byte-for-byte the tested temporary helper. Python compilation, document command syntax, relative links, and whitespace were checked before saving this record.
- The five-second expiry and early SIGTERM cleanup paths were exercised. Abrupt forced termination of the main helper was not separately tested; a separate watchdog was scheduled in each run.
- The complete documented reproduction sequence has not been rerun end to end from a fresh VM or second host.
- These requests originated inside the VM. Earlier Mac-originated HTTP through SSH is recorded [separately](8-host-to-vm-http.md).
- A timeout in another environment would need further evidence; this controlled result does not establish that every exit 28 is a firewall problem.
- The four practiced failure categories now have guided observations. Independent diagnosis/recovery, explanation without supplied cause, final practical review, and human acceptance of issue #8 remain.
