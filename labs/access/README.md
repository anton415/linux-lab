# File execution permissions

Day 3 exercise, related to [issue #3](https://github.com/anton415/linux-lab/issues/3).
This covers the file execution permission drill. Subsequent SSH and cross-user practice is recorded in the [follow-up evidence](../../evidence/3-ssh-file-access.md); one guided file-access case was completed, and the additional independent repeat was skipped at Anton's request.

Run from the repository root inside a Linux VM. The fixture only prints a synthetic message.

## Reproduce the failure

```bash
chmod 644 labs/access/hello.sh
ls -l labs/access/hello.sh
./labs/access/hello.sh
```

Expected permissions: `-rw-r--r--`. Direct execution should report `Permission denied`.

## Repair and verify

```bash
chmod u+x labs/access/hello.sh
ls -l labs/access/hello.sh
./labs/access/hello.sh
```

Expected permissions: `-rwxr--r--`. Expected output: `Hello from the Linux permissions lab.`
Only the owner gains execute permission. No other files or accounts are changed.
Git stores an executable flag rather than the full permission mode, so explicitly set `644` before repeating the drill from another checkout.
