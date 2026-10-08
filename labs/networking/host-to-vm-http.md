# HTTP from macOS to the Lima VM

Related to [issue #8](https://github.com/anton415/linux-lab/issues/8).
This exercise sends HTTP from the Mac through an explicit SSH tunnel to a
synthetic server inside the existing Linux VM.

## Prerequisites and path

Use the existing running VM, working key-based SSH access, and an available
loopback port 18080 on the Mac and port 8080 in the guest. macOS needs Lima,
OpenSSH, and curl; the guest needs Python 3 and GNU timeout.

The observed VM uses Lima plain mode. Automatic dynamic port forwarding is
disabled in that mode; see [Lima plain mode](https://lima-vm.io/docs/config/plain/).
No VM configuration or firewall change is needed for this exercise.

The path is:

```text
Mac 127.0.0.1:18080 -> SSH connection -> VM 127.0.0.1:8080
```

Each loopback address refers to its own machine. This tests HTTP through SSH,
not direct routing from the Mac to the VM network-interface address. Using a
numeric loopback address does not test DNS.

## Prepare and start from a Mac terminal

Change the VM alias if needed. Check that the intended ports are free first:

```bash
vm_name=linux-lab-lima
lsof -nP -iTCP:18080 -sTCP:LISTEN
limactl shell "$vm_name" ss -H -ltn 'sport = :8080'
```

Both checks should show no listener. If either is occupied, identify it before
continuing; do not stop an unrelated process.

Create a private temporary directory containing only the synthetic response:

```bash
fixture_dir=$(limactl shell "$vm_name" mktemp -d /tmp/linux-lab-host-http.XXXXXX)
printf 'Served by the Linux VM: synthetic HTTP lab OK\n' |
  limactl shell "$vm_name" tee "$fixture_dir/index.html" >/dev/null
```

Start the explicit tunnel and bounded server in the foreground:

```bash
ssh -n -T -F "$HOME/.lima/$vm_name/ssh.config" -S none \
  -o ControlMaster=no -o ControlPersist=no -o BatchMode=yes \
  -o ConnectTimeout=5 -o ExitOnForwardFailure=yes \
  -L 127.0.0.1:18080:127.0.0.1:8080 \
  "lima-$vm_name" timeout --signal=TERM 1200s \
  python3 -u -m http.server 8080 --bind 127.0.0.1 --directory "$fixture_dir"
```

Wait for the server startup message. The server is limited to 20 minutes;
the tunnel closes when the remote command ends.

## Request from another Mac terminal

Ensure this terminal is on the Mac, not inside `limactl shell`.

```bash
curl --noproxy '*' -i --connect-timeout 3 --max-time 5 http://127.0.0.1:18080/
```

Expected: HTTP 200 and `Served by the Linux VM: synthetic HTTP lab OK`.

Then request a missing resource and save the exit status immediately:

```bash
curl --noproxy '*' -f -i --connect-timeout 3 --max-time 5 http://127.0.0.1:18080/missing-page
http_lab_status=$?
printf 'Exit status: %s\n' "$http_lab_status"
```

Expected: HTTP 404 and curl exit 22. This is an HTTP-level error: a server
answered, but the requested resource was absent. A failed TCP connection would
not return this HTTP response. Inspect the actual output if the bounded setup
has expired before a request.

## Cleanup and evidence

Allow the 20-minute limit to stop the server, or stop it early from the VM after
using `ss -ltnp 'sport = :8080'` and `ps -p <PID> -o pid,user,args` to verify the
specific Python exercise process and its fixture directory. Send SIGTERM only
to that verified process. Never reuse a PID from an earlier session.

After the SSH command ends, repeat the two listener checks above. Both should
show no listener. Synthetic temporary files can remain for inspection; they are
not tracked in Git.

The [observed exercise record](../../evidence/8-host-to-vm-http.md) distinguishes
human interpretation, supplied setup/commands, exact results, and untested paths.
