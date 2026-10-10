# Networking health check

Related issue: [#8](https://github.com/anton415/linux-lab/issues/8).

Run inside the Linux lab VM, from the repository root:

```bash
bash labs/networking/check.sh
bash labs/networking/check.sh example.com 80
bash labs/networking/check.sh 127.0.0.1 8080
```

The first argument is the hostname, defaulting to `example.com`. The second is the HTTP port, defaulting to `80`. The loopback example needs an HTTP service already listening on port 8080; the earlier exercise server was stopped during cleanup.

The script performs two checks in order:

1. Resolve the hostname to IPv4 addresses using the system's configured name-resolution mechanism (`getent ahostsv4`). Failure prints `DNS FAIL` and stops the script. With a numeric IPv4 argument, this does not prove a DNS-server lookup occurred.
2. Request `http://HOST:PORT/` directly, without a proxy. Curl discards the body, shows errors, limits connection setup to 3 seconds and the HTTP operation to 5 seconds, and treats HTTP statuses 400 and above as failures. These curl limits do not bound the preceding name-resolution check.

| Exit status | Meaning |
|---|---|
| `0` | Name resolution succeeded and curl completed successfully; redirect responses also count as success and are not followed. |
| `1` | Name resolution or the HTTP check failed. Read the stage message and curl error to identify the failure. |

Check the exit status immediately after a run:

```bash
bash labs/networking/check.sh example.com 80
echo "$?"
```

For example, curl error 7 indicates a connection failure; error 22 accompanied by HTTP 404 means the HTTP server answered with an error status. Both are reported as `HTTP FAIL`, but their diagnostic messages differ.

The initial implementation is a small HTTP check; it does not inspect response-body contents or operate the target service. See the [exercise evidence](../../evidence/8-t1-networking.md) for tested cases, human work, assistance, and remaining issue criteria.

## HTTP from the Mac

Use the [host-to-VM HTTP runbook](host-to-vm-http.md) for the explicit SSH tunnel,
synthetic server, successful request, missing-page response, and bounded cleanup.
See the [follow-up evidence](../../evidence/8-host-to-vm-http.md) for the observed
Mac requests and human interpretation.

## Blocked connection in the VM

The [bounded packet-drop exercise](blocked-connection.md) demonstrates a
connection timeout while the HTTP server remains listening, followed by recovery
when the temporary rule is removed. See the [guided evidence](../../evidence/8-blocked-connection.md).
