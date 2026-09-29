# Hands-on lab artifacts

Create `labs/<topic>/` when its issue starts. Keep the runnable script/configuration
next to a short README with prerequisites, commands, expected observations, one
bounded failure/recovery exercise, and cleanup. Each exercise should be repeatable
from a documented starting state.

Examples of future artifacts: a permissions fixture, a systemd unit, an Nginx site,
an archive/restore script, or an Ansible playbook. The seed VM scripts live in `vm/`.

For L1.1, read `vm/cloud-init/base.yaml`, explain each setting, launch a named VM,
and run the supplied checks. Then create a second clean VM from the same commit.
Write down what matched, what changed, and what is still unverified. This is the
first learning task; later exercise implementations are intentionally left to Anton.
