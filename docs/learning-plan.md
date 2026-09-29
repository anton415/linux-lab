# Linux learning plan

## Outcome and sequence

Build operational skill through a repeatable loop: understand one concept, implement a small change, introduce a bounded fault, diagnose and recover, then recreate the result from committed inputs. Anton performs the learning core and first diagnosis.

Start with L1.1. All issues begin in **Backlog** for human scope/sequence review. L1.1 needs human acceptance of the proposed VM baseline; future issues need refinement when their prerequisites are met. Dates are deliberately unset. L6 waits for finance-lab service delivery; L7 is optional and may proceed after its own dependencies without waiting for L6.

The seed configuration is infrastructure scaffolding. It does not complete any lab or demonstrate a human skill. Use the [workflow](workflow.md), [VM guide](vm.md), and [evidence template](../evidence/TEMPLATE.md).

## Milestones and small issues

### [L1 — Recreate and understand one Linux VM](https://github.com/anton415/linux-lab/milestone/1)

Create two clean VMs from checked-in inputs; explain shell operations, permissions, SSH, processes, and logs. Record actual image/tool versions and one diagnosed failure. No milestone passes on generated code alone.

| Issue | Prerequisites | Hands-on artifact / application |
|---|---|---|
| [L1.1 — Boot and recreate the baseline Ubuntu VM](https://github.com/anton415/linux-lab/issues/1) | None | `evidence/<issue>-vm-baseline.md` |
| [L1.2 — Use files, pipes, searches, and archives on a synthetic fixture](https://github.com/anton415/linux-lab/issues/2) | L1.1 | `labs/files/README.md and synthetic fixture files` |
| [L1.3 — Create a lab user and diagnose SSH or permission denial](https://github.com/anton415/linux-lab/issues/3) | L1.2 | `labs/access/README.md and reproducible user/permission setup` |
| [L1.4 — Trace a process, its signals, packages, and logs](https://github.com/anton415/linux-lab/issues/4) | L1.2 | `labs/processes/README.md and a bounded process fixture` |

### [L2 — Build and operate finance-lab locally](https://github.com/anton415/linux-lab/milestone/2)

Build an exact finance-lab revision in Linux, operate a small systemd exercise, serve static assets with Nginx, and diagnose one networking failure. Local synthetic-data evidence only.

| Issue | Prerequisites | Hands-on artifact / application |
|---|---|---|
| [L2.1 — Build a pinned finance-lab revision in a clean Linux VM](https://github.com/anton415/linux-lab/issues/5) | L1.3, L1.4 | `labs/finance-build/README.md and a small build script`; [finance-lab #54](https://github.com/anton415/finance-lab/issues/54) |
| [L2.2 — Operate and repair one small systemd service](https://github.com/anton415/linux-lab/issues/6) | L1.3, L1.4 | `labs/systemd/ lab service, unit, and README` |
| [L2.3 — Serve the finance-lab static build through local Nginx](https://github.com/anton415/linux-lab/issues/7) | L2.1, L2.2 | `labs/nginx/ site configuration and deployment instructions`; [finance-lab #55](https://github.com/anton415/finance-lab/issues/55) |
| [L2.4 — Diagnose DNS, listening ports, and firewall reachability](https://github.com/anton415/linux-lab/issues/8) | L2.3 | `labs/networking/ commands, firewall configuration, and runbook`; [finance-lab #55](https://github.com/anton415/finance-lab/issues/55) |

### [L3 — Recover data and automate configuration](https://github.com/anton415/linux-lab/milestone/3)

Restore a synthetic export by checksum and application validation, make checks report failures correctly, and recreate the approved VM/application configuration with Ansible. Explain changed versus unchanged runs.

| Issue | Prerequisites | Hands-on artifact / application |
|---|---|---|
| [L3.1 — Back up and restore a synthetic finance-lab export](https://github.com/anton415/linux-lab/issues/9) | L2.3, L1.2 | `labs/backup/ archive/restore script and runbook`; [finance-lab #56](https://github.com/anton415/finance-lab/issues/56) |
| [L3.2 — Write a Bash check that fails usefully](https://github.com/anton415/linux-lab/issues/10) | L2.4 | `labs/healthcheck/ check.sh and controlled fixtures` |
| [L3.3 — Recreate the approved guest configuration with Ansible](https://github.com/anton415/linux-lab/issues/11) | L3.1, L3.2 | `ansible/ inventory.example and one focused playbook`; [finance-lab #55](https://github.com/anton415/finance-lab/issues/55), [finance-lab #56](https://github.com/anton415/finance-lab/issues/56) |

### [L4 — Operate multiple machines and bounded resources](https://github.com/anton415/linux-lab/milestone/4)

Recreate a two-VM route/access exercise; diagnose a bounded filesystem problem and CPU/memory limits; retain cleanup and recovery evidence. Avoid claims of physical high availability.

| Issue | Prerequisites | Hands-on artifact / application |
|---|---|---|
| [L4.1 — Recreate and troubleshoot a two-VM network](https://github.com/anton415/linux-lab/issues/12) | L3.3 | `labs/multi-vm/ topology, configuration, and checks` |
| [L4.2 — Recover from a bounded filesystem capacity problem](https://github.com/anton415/linux-lab/issues/13) | L1.4, L3.1 | `labs/storage/ loopback filesystem setup and recovery guide` |
| [L4.3 — Measure and limit a synthetic CPU or memory workload](https://github.com/anton415/linux-lab/issues/14) | L2.2 | `labs/resources/ systemd resource configuration and diagnostic notes`; [finance-lab #65](https://github.com/anton415/finance-lab/issues/65), [finance-lab #66](https://github.com/anton415/finance-lab/issues/66) |

### [L5 — Package and inspect containers](https://github.com/anton415/linux-lab/milestone/5)

Run the static finance-lab build in a repeatable container and explain process, mount, user, network, and cgroup boundaries through a bounded fault drill. No production orchestration required.

| Issue | Prerequisites | Hands-on artifact / application |
|---|---|---|
| [L5.1 — Package the static finance-lab build in a local container](https://github.com/anton415/linux-lab/issues/15) | L2.3, L3.2 | `labs/containers/ Dockerfile and run instructions`; [finance-lab #54](https://github.com/anton415/finance-lab/issues/54), [finance-lab #55](https://github.com/anton415/finance-lab/issues/55) |
| [L5.2 — Inspect container boundaries and diagnose one failure](https://github.com/anton415/linux-lab/issues/16) | L5.1, L4.3 | `labs/containers/ isolation and recovery exercise`; [finance-lab #65](https://github.com/anton415/finance-lab/issues/65) |

### [L6 — Apply Linux operations to the evaluation service](https://github.com/anton415/linux-lab/milestone/6)

Conditional on approved finance-lab #62–#65 delivery: operate the actual service under systemd and contribute measured diagnosis evidence to #66. Do not implement a competing API, worker, or metrics system.

| Issue | Prerequisites | Hands-on artifact / application |
|---|---|---|
| [L6.1 — Operate the approved finance-lab evaluation service on Linux](https://github.com/anton415/linux-lab/issues/17) | L3.3, L4.3; finance-lab #62–#65 delivered | `labs/evaluation-service/ operational configuration and handoff evidence`; [finance-lab #62](https://github.com/anton415/finance-lab/issues/62), [finance-lab #63](https://github.com/anton415/finance-lab/issues/63), [finance-lab #64](https://github.com/anton415/finance-lab/issues/64), [finance-lab #65](https://github.com/anton415/finance-lab/issues/65) |
| [L6.2 — Contribute a Linux diagnosis exercise to the service runbook](https://github.com/anton415/linux-lab/issues/18) | L6.1 | `labs/evaluation-service/ diagnostic procedure and evidence for #66`; [finance-lab #66](https://github.com/anton415/finance-lab/issues/66) |

### [L7 — Extend to infrastructure as code and cloud](https://github.com/anton415/linux-lab/milestone/7)

Optional after review: recreate local infrastructure through a supported IaC provider, practice a small local Kubernetes deployment, and only with explicit budget approval recreate one cloud VM. Each experiment records provider versions, limits, teardown, and costs where applicable.

| Issue | Prerequisites | Hands-on artifact / application |
|---|---|---|
| [L7.1 — Recreate a small local environment through infrastructure as code](https://github.com/anton415/linux-lab/issues/19) | L4.1, L3.3 | `terraform/local/ provider configuration and recreation guide` |
| [L7.2 — Practice a minimal local Kubernetes deployment](https://github.com/anton415/linux-lab/issues/20) | L5.2, L4.1 | `kubernetes/ minimal manifests and failure/recovery notes` |
| [L7.3 — Plan and recreate one budget-limited cloud VM](https://github.com/anton415/linux-lab/issues/21) | L7.1, L2.4; explicit account and budget approval | `terraform/yandex/ or another explicitly selected provider, plus teardown guide` |

## Definition of done

- The issue delivers its named script, configuration, or repeatable experiment.
- Relevant commands and failures have actual observed results, linked to exact revisions and versions.
- Recovery and cleanup are exercised where relevant; recreation is verified to the scope claimed.
- Anton explains the result and repeats the key step without a supplied solution.
- Review and human acceptance are complete; untested claims remain explicit.

A milestone closes only after its issue criteria and the milestone outcome are demonstrated. A generated document, watched lesson, or green syntax check cannot substitute for operational evidence.

## Deliberately deferred

MicroCloud/OpenStack, distributed storage, a database for the current static app, managed Kubernetes, and new hardware are not prerequisites. Revisit them only after a concrete lab limitation. Cloud IAM, billing, quotas, managed services, and physical failure need separate evidence; local VMs do not prove them.

Use official tool documentation and the manuals shipped with the guest for each step. The practical exercises are the core curriculum; extra courses and certification purchases are optional.

## Planning source and drift

GitHub issues are authoritative for current scope, state, and evidence. This document is an index and dependency overview. Initial plan: 2026-09-29. The [finance-lab integration map](finance-lab-integration.md) records inspected work and prevents parallel product implementations. Recheck that map before a cross-repository handoff.
