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
- This session did not demonstrate every required distinction between name-resolution failure, absent listener, blocked reachability, and HTTP-level error. The [follow-up](8-host-to-vm-http.md) adds practiced hostname-lookup, absent-tunnel-listener, and HTTP-error distinctions; blocked reachability and independent diagnosis remain.
- Both HTTP exercise requests originated inside the VM; a host-to-VM request was not tested in this drill. The [2026-10-08 follow-up](8-host-to-vm-http.md) subsequently verified HTTP from the Mac through an explicit SSH tunnel.
- The original diagnostic fixture was temporary. The [follow-up runbook](../labs/networking/host-to-vm-http.md) now records repeatable synthetic-server and missing-page steps; a full run of the combined runbook, fresh-VM recreation, and second-host reproduction remain unverified.
- Publication does not establish formal issue acceptance. Issue #8 remains open; its acceptance criteria and project status are unchanged.
