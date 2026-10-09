import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import threading
import time

lifetime = int(sys.argv[1])
assert 1 <= lifetime <= 900
folder = Path(__file__).resolve().parent
tag = "linux-lab-" + folder.name
rule = ["-i", "lo", "-d", "127.0.0.1/32", "-p", "tcp", "--dport", "18081",
        "-m", "comment", "--comment", tag, "-j", "DROP"]
base = ["/usr/sbin/iptables", "-w", "3"]
delete = base + ["-D", "INPUT"] + rule
stop = threading.Event()
for signum in (signal.SIGTERM, signal.SIGINT, signal.SIGHUP):
    signal.signal(signum, lambda *_: stop.set())

existing = subprocess.run(base + ["-C", "INPUT"] + rule, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
if existing.returncode != 1:
    raise SystemExit("Rule already present or firewall check failed; no change made.")

watchdog_code = (
    "import subprocess,sys,time; "
    "time.sleep(float(sys.argv[1])); "
    "subprocess.run(sys.argv[2:],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)"
)
watchdog = subprocess.Popen(
    [sys.executable, "-c", watchdog_code, str(lifetime), *delete],
    stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    start_new_session=True,
)
try:
    subprocess.run(base + ["-I", "INPUT", "1"] + rule, check=True)
    state = {"lease_pid": os.getpid(), "watchdog_pid": watchdog.pid,
             "comment": tag, "rule": rule, "expires_at": time.time() + lifetime}
    (folder / "lease-state.json").write_text(json.dumps(state))
    print(json.dumps({"temporary_rule_active": True, "seconds": lifetime,
                      "lease_pid": os.getpid(), "watchdog_pid": watchdog.pid}), flush=True)
    stop.wait(lifetime)
finally:
    check = subprocess.run(base + ["-C", "INPUT"] + rule, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if check.returncode == 0:
        subprocess.run(delete, check=True)
    elif check.returncode != 1:
        raise RuntimeError("Cleanup check failed; independent watchdog remains scheduled.")
    if watchdog.poll() is None:
        watchdog.terminate()
    watchdog.wait(timeout=5)
    print("Temporary rule removed; watchdog stopped.", flush=True)
