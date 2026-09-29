# linux-lab

Anton's practical Linux learning path for DevOps, AgentOps, and AI platform engineering.
Each issue produces something reproducible: a script, configuration, small experiment,
or recovery procedure, with evidence that Anton can explain and repeat.

## Start here

1. Read the [learning plan](docs/learning-plan.md) and start with **L1.1**.
2. Follow the [VM guide](docs/vm.md) to create an Ubuntu Server lab.
3. Complete one small issue at a time using the [workflow](docs/workflow.md).
4. Retain a short, reviewed [evidence record](evidence/TEMPLATE.md).

The seed includes a cloud-init configuration and VM creation/check scripts. It does
not claim a completed learning milestone: the first real VM boot, clean rebuild,
and human demonstration are acceptance criteria of L1.1.

## Quick start

Prerequisites: Git, Bash, and [Multipass](https://canonical.com/multipass/docs/latest/how-to-guides/install-multipass/)
installed by the machine owner. The default VM uses 2 CPUs, 4 GiB RAM, and a 20 GiB
virtual disk. Keep enough resources free for the host.

```bash
git clone https://github.com/anton415/linux-lab.git
cd linux-lab
bash vm/scripts/create.sh
bash vm/scripts/check.sh
multipass shell linux-lab-01
```

The scripts only target the named VM. They do not install host software, share host
directories, or delete existing machines. Stop a lab with `multipass stop linux-lab-01`.
See the VM guide for recreation, troubleshooting, and portability limits.

## Learning sequence

One VM → shell and administration → operate finance-lab locally → recovery and
automation → multiple machines and resource limits → containers → infrastructure
as code and optional cloud/Kubernetes practice.

The [finance-lab integration map](docs/finance-lab-integration.md) connects the
exercises to existing application issues. Finance-lab currently builds static
React/Vite files; its browser data stays in browser storage. Linux server backups
do not automatically back up those budgets.

## Repository layout

```text
vm/cloud-init/       Base guest configuration
vm/scripts/          Create and inspect a named VM
labs/                Small exercises and their implementation artifacts
evidence/            Reviewed, synthetic evidence and a reusable template
docs/                Learning plan, workflow, VM guide, integration boundaries
.github/             Issue and pull-request templates
```

Add Ansible, container, Terraform, or Kubernetes files when their issue becomes
active. Keep credentials, VM disks, state files, and raw logs outside Git.

## How work is tracked

GitHub issues hold current scope and acceptance criteria. Milestones group skill
outcomes. The shared [Finance Lab Development project](https://github.com/users/anton415/projects/9)
uses `Backlog → Ready → In progress → Review → Done`. Filter by
`repo:anton415/linux-lab` to see this track. Human decisions and demonstrations remain
part of completion; an AI-generated implementation is not evidence of human mastery.

See [AGENTS.md](AGENTS.md) before using a coding assistant.
