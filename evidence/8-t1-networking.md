# Evidence: T1 networking checks and HTTP binding failure

- Related issue: [#8 — networking diagnosis](https://github.com/anton415/linux-lab/issues/8).
- Date: 2026-10-06.
- Base linux-lab revision: `e84cdb2ce6e6069c864665cffcb81af8ba6e7c44`.
- Environment: existing local Lima Linux VM; Python 3.12.3 was reported by the exercise server. VM image identity and other tool versions were not reverified.
- Scope: basic network inspection plus one guided listener-address failure, repair, and cleanup. This is partial issue evidence, not full acceptance.
- Planned time: a separate estimate for this combined session was not recorded.
- Actual active time: approximately **2 hours**, reported by Anton, excluding breaks and covering the networking checks and HTTP failure exercise.
- Privacy: `<VM_IP>`, `<GATEWAY>`, `<fixture>`, and `<pid>` replace machine-specific values. Commands below containing these markers require substitution; raw terminal history and logs are not included.

## Working network checks

| Command | Observed result | Evidence source |
|---|---|---|
| `sudo ss -ltnp` | SSH listeners on `0.0.0.0:22` and `[::]:22`; local name-resolution listeners on port 53 | Anton ran the command; Codex read the terminal output |
| `ip -br addr` | Loopback addresses present; `eth0` was UP with an IPv4 address | Anton ran the command; terminal output and a separate Codex check agreed |
| `ip route` | Default route via `<GATEWAY>` on `eth0` | Codex ran this check and explained the result |
| `getent ahostsv4 example.com` | Two IPv4 addresses, each with STREAM/DGRAM/RAW entries | Anton ran the command; Codex read the terminal output |
| `curl -I --connect-timeout 5 --max-time 10 https://example.com` | `HTTP/2 200` response headers | Anton ran the command; Codex read the terminal output |

These observations establish a configured route, successful name resolution, and one successful HTTPS request. They do not establish reachability of every destination or independent diagnostic proficiency.

## Bounded failure and recovery

Codex prepared a temporary fixture containing only the synthetic body `Synthetic HTTP lab: OK`, a `bind-address` configuration file, and a start script running Python's standard HTTP server on port 8080. Initially the configured address was `127.0.0.1`.

| Check or action | Observed result | Evidence source |
|---|---|---|
| `curl --noproxy '*' --silent --show-error --connect-timeout 2 --max-time 3 http://<VM_IP>:8080/` | Exit 7: connection failure while the exercise process remained running | Codex verified the initial fault during setup |
| `sudo ss -ltnp` | Exercise listener at `127.0.0.1:8080`, owned by Python | Anton ran the command; Codex read the output and independently checked the process |
| `curl --noproxy '*' -i --connect-timeout 3 --max-time 5 http://127.0.0.1:8080/` | `HTTP/1.0 200 OK` and the expected synthetic body | Anton ran the command after choosing loopback; Codex read the response |
| Edit `<fixture>/bind-address` to the IPv4 address assigned to `eth0` | First edit had a missing digit; Anton corrected it after Codex identified the mismatch | Codex read and compared the saved configuration with the actual interface address |
| Stop the identified exercise process with SIGTERM and restart its existing start script | New listener at `<VM_IP>:8080` | Codex verified process identity, performed the restart, and checked `ss` |
| `curl --noproxy '*' --silent --show-error --connect-timeout 3 --max-time 5 --write-out '\nHTTP_STATUS=%{http_code}\n' http://<VM_IP>:8080/` | Exit 0, HTTP 200, and the expected synthetic body | Codex verified recovery at the original target |
| Stop the replacement exercise process with SIGTERM; inspect the process and `ss -H -ltn 'sport = :8080'` | Process stopped; no listener remained on port 8080 | Codex verified cleanup |

No SSH service, firewall rule, DNS setting, or default route was changed. The temporary synthetic files and local verification records were retained for review; the HTTP process was stopped.

## Human diagnosis and assistance

Anton proposed checking the IP address and port, and using ping to determine whether the server was running. Codex explained that an ICMP response cannot establish that an HTTP service is listening, and suggested the already-practiced socket inspection command.

Anton initially noticed only the SSH rows. Codex pointed out the Python listener and the address mismatch. Anton then selected `127.0.0.1:8080` for the next request, edited the binding configuration, corrected the address typo, and explained the cause in his own words:

> Because was used different listener `127.0.0.1:8080` and it listens only on loopback.

The observed cause was a listening-address mismatch: the process was available on loopback, while the failed request targeted the VM's network-interface address. Codex supplied diagnostic hints, the curl commands, and the restart/verification/cleanup. This was a guided diagnosis, not an independent diagnosis without a supplied solution.

## Bash health-check implementation and review

Anton wrote `labs/networking/check.sh`, first implementing name resolution, then adding the HTTP stage. The final code uses a hostname and optional port, returns 1 on name-resolution failure, continues after name-resolution success, and returns 0 or 1 according to curl's result.

Codex provided the Bash structure and command/options, reviewed the first attempt, and pointed out missing `then`/`fi` syntax and a literal placeholder mistakenly used in an output message. Anton made the corrections and wrote both conditional blocks. Codex did not edit the script.

The first DNS-only version passed syntax checks and valid-hostname, invalid-hostname, and default-hostname checks. After Anton added HTTP, Codex verified the final syntax with `bash -n labs/networking/check.sh` and ran the following behavior checks through `bash labs/networking/check.sh [HOST] [PORT]`:

| Case | Observed output and exit status | Result |
|---|---|---|
| Disposable local server returns HTTP 200 | `DNS OK`, `HTTP OK`; exit 0 | Pass |
| Same server returns HTTP 404 | `DNS OK`, `HTTP FAIL`, curl diagnostic containing 404; exit 1 | Pass |
| Hostname `linux-lab-test.invalid` | `DNS FAIL`; exit 1; no HTTP request reached the local test server | Pass |
| Loopback port reserved by a socket that was not listening | `DNS OK`, `HTTP FAIL`, curl error 7; exit 1 | Pass |
| No arguments: `example.com`, HTTP port 80 | `DNS OK: example.com`, `HTTP OK: http://example.com:80/`; exit 0 | Pass |

The behavior checks used a temporary Python HTTP server bound to loopback on a dynamically allocated port. Codex stopped that server and closed all test sockets in cleanup. A 15-second limit bounded each review invocation; this external test limit is not part of the script. HTTP timeout behavior was configured but a deliberately stalled response was not tested.

The [usage instructions](../labs/networking/README.md) document arguments, exit statuses, and curl behavior. The script and documentation accompany this evidence record.

- Planned time: a separate estimate for writing this script was not recorded.
- Actual active time for writing/correcting the script: **30 minutes**, reported by Anton, excluding breaks; separate from the earlier two-hour networking exercise.
- Verified Bash: `GNU bash, version 5.2.21(1)-release (aarch64-unknown-linux-gnu)`.
- Verified curl: `curl 8.5.0 (aarch64-unknown-linux-gnu) libcurl/8.5.0 OpenSSL/3.0.13 zlib/1.3 brotli/1.1.0 zstd/1.5.5 libidn2/2.3.7 libpsl/0.21.2 (+libidn2/2.3.7) libssh/0.10.6/openssl/zlib nghttp2/1.59.0 librtmp/2.3 OpenLDAP/2.6.10`.

## Remaining work and limits

- The DNS/HTTP health-check script is implemented and its tested outcomes are recorded above. Remaining issue acceptance still requires the broader human demonstration and review.
- This session did not demonstrate every required distinction between name-resolution failure, absent listener, blocked reachability, and HTTP-level error. The [HTTP follow-up](8-host-to-vm-http.md) adds practiced hostname-lookup, absent-tunnel-listener, and HTTP-error distinctions. The [blocked-connection follow-up](8-blocked-connection.md) adds a guided timeout/recovery case; independent diagnosis remains.
- Both HTTP exercise requests originated inside the VM; a host-to-VM request was not tested in this drill. The [2026-10-08 follow-up](8-host-to-vm-http.md) subsequently verified HTTP from the Mac through an explicit SSH tunnel.
- The original diagnostic fixture was temporary. The [follow-up runbook](../labs/networking/host-to-vm-http.md) now records repeatable synthetic-server and missing-page steps; a full run of the combined runbook, fresh-VM recreation, and second-host reproduction remain unverified.
- Publication does not establish formal issue acceptance. Issue #8 remains open; its acceptance criteria and project status are unchanged.

## Port-mismatch practical review — 2026-10-10

- Related to issue #8; source revision `9426756f795ebb02e1d44dcd951db2cf8f988192`.
- Existing Lima VM; loopback-only synthetic HTTP fixture. No firewall, SSH, or VM configuration changes. VM image and tool versions were not reverified for this review.
- Planned time: approximately 15 minutes. Actual active time: 20 minutes (reported by Anton).
- `<fixture>` below means the unique temporary exercise directory; process IDs, account details, and raw terminal history are omitted.

Codex prepared a temporary `start.sh` launcher that read a `port` file and started Python's HTTP server with `timeout --signal=TERM --kill-after=5s 1200s`, bound to `127.0.0.1` and serving only a synthetic `www/index.html`. The configured port was 18083; the required client target was `http://127.0.0.1:18082/`. Bash syntax passed. Before the human investigation, Codex verified a successful response on 18083 and health-check failure with exit 1 on 18082. The fault's cause was not supplied in the exercise prompt.

Anton's first hypothesis was that nothing was listening on 18082. He chose a socket check. The terminal first showed a check of the earlier exercise's port 18081, followed by an edited check with no matching listener; Codex separately confirmed the absence of a listener on 18082. An earlier printed exit status of 0 was unrelated to an HTTP request and was not treated as recovery evidence.

Anton next proposed checking whether the server process was running and reading its logs. When he was unsure of the commands, Codex supplied:

```bash
ps -eo pid,ppid,user,stat,args | grep '[h]ttp.server'
cat <fixture>/server.log
```

The process arguments and startup log both showed port 18083. Anton identified this port and then proposed changing it to 18082 and restarting the server. Codex verified the exact exercise process and owner, stopped that process with SIGTERM, changed the temporary port configuration, and restarted the bounded launcher. The old listener disappeared and the new listener appeared on 18082.

Anton first verified `LISTEN` on `127.0.0.1:18082` with `ss`. Codex explained that the HTTP check was still needed and supplied the health-check invocation and immediate exit-status capture. From the Linux lab repository, the equivalent commands are:

```bash
bash labs/networking/check.sh 127.0.0.1 18082
http_lab_status=$?
printf 'Exit status: %s\n' "$http_lab_status"
```

Codex read the observed terminal result:

```text
DNS OK: 127.0.0.1
HTTP OK: http://127.0.0.1:18082/
Exit status: 0
```

The numeric loopback target does not demonstrate a DNS-server query. The health check verifies a successful HTTP request; it discards the response body and does not print the numeric HTTP status.

After verification, Codex stopped only the verified exercise server with SIGTERM. Both bounded launcher sessions ended, and absence of listeners on 18082 and 18083 was confirmed. Temporary synthetic files and logs were retained for inspection. The automatic 20-minute expiry and forced-kill fallback were not exercised because cleanup used SIGTERM.

Learning evidence: Anton proposed the initial hypothesis and investigation strategy, identified the port mismatch from the evidence, and proposed the correct repair. Diagnostic command syntax and HTTP verification commands were supplied; Codex performed the configuration edit, restart, and cleanup. This is an assisted practical review with human diagnosis and repair reasoning, not a fully unaided execution or a fresh-VM reproduction. It does not establish the separate process-lab acceptance criteria or close issue #8.

## Final T1 diagnostic practical — 2026-10-10

The [final process practical](4-processes-logs.md#final-t1-practical-missing-command-and-independent-repair--2026-10-10)
adds human-led diagnosis of an unavailable executable causing startup failure
and no listener on port 18085. Anton selected the diagnostic commands, identified
and specified the repair, and chose the successful HTTP verification and targeted
shutdown. Codex executed the commands and provided limited formatting/status-read
help. Planned time was 15 minutes; actual active time was 30 minutes, counted once
in that process record. No new DNS, firewall or host-to-VM test was performed.
This supplements the earlier guided networking evidence; final review and human
acceptance of issue #8 remain pending.
