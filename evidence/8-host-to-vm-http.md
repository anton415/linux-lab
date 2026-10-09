# Evidence: Mac-to-VM HTTP through SSH

- Issue / PR: Related to [#8](https://github.com/anton415/linux-lab/issues/8); partial acceptance evidence.
- Date: 2026-10-08 (Europe/Moscow).
- Revision at exercise time: `85108659a9cf0f528a4f0c8087b407504200984f`. The fixture was temporary and outside the repository; it did not use the process-lab code from that revision.
- Documentation branch: `issue-8-host-http`, based on networking commit `614b9309836be6087106ae0f47ce8b0491013c6e`.
- Environment: macOS/aarch64 host; Lima 2.2.0, VZ, aarch64 guest, plain mode; observed Python HTTP server version 3.12.3. The running guest image digest/release and curl/OpenSSH versions were not reverified.
- Reproduction: [Mac-to-VM HTTP runbook](../labs/networking/host-to-vm-http.md). The runbook records the equivalent manual setup; a fresh end-to-end run of its combined command sequence has not been performed.
- Planned time: approximately 5 minutes for the first host request and 5 minutes for the hostname-lookup exercise; no separate estimate for the 404 or absent-listener follow-ups.
- Actual active time: not yet reported for these follow-ups; separate from the earlier networking and process-lab time records. An estimate was requested for the initial Mac HTTP/404 checks before the subsequent hostname and absent-listener exercises.

## Observations

Codex inspected the app terminal and the supervised server output. The first
request visibly ran at the Mac prompt after Anton exited the VM shell. Machine
account names, PIDs, private paths, and temporary-directory identifiers are omitted.

| Command or check | Expected | Observed / exit status | Result |
|---|---|---|---|
| VM address/listener inspection and Mac port check | Existing network and free exercise ports | Guest network interface UP; no guest listener on 8080; Mac loopback port 18080 available | pass |
| Start Python HTTP server on VM loopback 8080 through a separate SSH connection forwarding Mac loopback 18080 | Bounded local HTTP path | Server startup message; Mac listener belonged to SSH at `127.0.0.1:18080` | pass |
| Mac: `curl --noproxy '*' -i --connect-timeout 3 --max-time 5 http://127.0.0.1:18080/` | HTTP success from VM fixture | HTTP/1.0 200 OK; synthetic body `Served by the Linux VM: synthetic HTTP lab OK`; curl exit status was not separately captured | pass for HTTP response |
| Mac: `curl --noproxy '*' -f -i --connect-timeout 3 --max-time 5 http://127.0.0.1:18080/missing-page`, immediate `http_lab_status=$?`, then print it | Missing-resource HTTP error | HTTP/1.0 404 File not found; curl error 22; saved exit status 22 | pass (expected error) |
| Verify the specific temporary Python server command, then send SIGTERM | Stop only the exercise server | Process disappeared; no VM listener on 8080 | pass |
| Check supervised SSH completion and `lsof -nP -iTCP:18080 -sTCP:LISTEN` | Remove the temporary tunnel | SSH supervision ended with exit 255 after shutdown; lsof showed no listener and returned 1 | listener cleanup verified |

## Follow-up checks after fixture cleanup

| Command or check | Observed result | Human interpretation |
|---|---|---|
| Mac curl request to `http://lnux-lab-test.invalid/`, followed by saved-status output | `Could not resolve host: lnux-lab-test.invalid`; exit 6; no HTTP response | Anton initially chose the connection stage, then corrected himself to hostname lookup before further assistant feedback. He subsequently explained that this failure occurred earlier than the HTTP-error case. |
| Codex: `lsof -nP -iTCP:18080 -sTCP:LISTEN` before the next request | No listener; exit 1 with no error output | Fixture cleanup left the Mac tunnel endpoint unavailable. |
| Mac curl request to `http://127.0.0.1:18080/`, followed by saved-status output | Failed to connect to port 18080; curl error and saved exit status 7; no HTTP response | Anton identified an error connecting to the server. |

Codex supplied each target and asked Anton to adapt the earlier curl command,
retain its proxy/timeout options, and save the exit status immediately. Terminal
line-editing artifacts prevent quoting the full final command text reliably;
the target addresses, curl diagnostics, and printed statuses were observed.
The typed synthetic hostname omitted a letter from the suggested target; it
still used the reserved `.invalid` suffix and failed name resolution.

The absent-listener case concerns the Mac endpoint of the stopped tunnel. It
does not establish that the VM or its SSH management service was down. Curl exit
7 alone is a connection-failure category; the separate listener check supports
the cause in this controlled exercise. Neither follow-up changed system settings
or started a new process requiring cleanup. No recovery request was run for these
two checks.

The SSH exit status during cleanup is separate from curl's HTTP result; a clean
zero SSH exit was not observed. Both listener-absence checks establish the
cleanup outcome. Synthetic temporary files were retained.

## Failure and recovery

- Initial hypothesis and diagnostic commands: Codex supplied the setup and curl commands, including the missing-page path and immediate status capture. Anton was asked to classify the response before an explanation was supplied.
- Bounded fault: a request to a missing resource on the working synthetic server.
- Human interpretation: Anton answered, "server respond with an error. missing page is 404 error".
- Cause established: the server was reachable and returned an HTTP error for the absent resource. This was not a failed TCP connection.
- Recovery: the working root URL had already returned HTTP 200 before the missing-page request. No server repair was needed; a post-error recovery request was not run.
- Cleanup: Codex verified and stopped the fixture, then checked both ports. No firewall, SSH service, DNS, or VM network setting was changed.

## Recreation

- Fresh VM: not tested.
- Second host: not tested.
- Direct Mac-to-guest-interface routing: not tested. The initial numeric-loopback HTTP requests did not test DNS; the later reserved-hostname request demonstrated a name-resolution failure, not a DNS-server outage.
- The explicit SSH tunnel is part of the observed path; success does not prove direct reachability of the VM interface address.
- The temporary server had a 20-minute limit and was stopped early after the exercise.

## Human demonstration and remaining work

Anton ran the requests from the Mac, correctly identified an HTTP 404 response,
self-corrected the name-resolution classification, and identified the later
connection failure. Codex explained that exit codes identify error types rather
than an ordered sequence. Codex prepared the server/tunnel, supplied the original
commands and later targets/options, reviewed output, performed cleanup, and wrote
this evidence.

These observations support the practiced distinction between hostname lookup,
a failed connection at the stopped Mac tunnel endpoint, and an HTTP error
response. They do not establish a complete diagnosis without a supplied cause or
diagnostic hints. The [2026-10-09 follow-up](8-blocked-connection.md) adds a guided
blocked-connection timeout and recovery. Independent failure diagnosis/recovery,
final practical review, and human acceptance of issue #8 remain.
