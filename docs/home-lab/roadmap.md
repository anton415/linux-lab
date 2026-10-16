# Home lab roadmap — October 2026 through December 2027

> **Status:** proposed learning/expansion roadmap (2026-10-16).
> **This document is not a purchase schedule or evidence of achieved skills.**

## Relationship to the career and Linux plans

The [frozen AI Platform / Agent Infrastructure transition plan](https://github.com/anton415/career/blob/main/planning/agentops-transition-plan-oct2026-jan2027.md)
is authoritative for the October–December 2026 project sequence (T0–T5),
weekly capacity, scope cuts and **January 4–15, 2027 application launch**.
The career repository may be private. No unfinished home lab purchase, rack,
course, Kubernetes migration, or certificate should postpone applications.
If the job search takes longer, continue learning **and** applying, adjusting
skills based on actual interview feedback; do not assume an early offer.

This home lab roadmap describes *where to practise*, not another parallel
curriculum. The existing [Linux learning plan](../learning-plan.md) and issues
remain the acceptance source for active `linux-lab` exercises. Some older
milestones (including the separate evaluation-service path) predate the
frozen career plan's `finance-lab-agent` scope; reconcile them in a **separate,
approved learning-plan issue**, not through this documentation PR.

The home lab should draw from already allocated project/study capacity,
rather than silently adding a new weekly commitment. Prefer one active
learning experiment alongside the main portfolio task.

## Phases and outcome gates

| Period | Engineering outcome | Lab implementation (proposed) | Evidence required before calling it complete |
| --- | --- | --- | --- |
| **Q4 2026** — foundations | Linux/SSH/process/network diagnosis; local development; basic containers, API-to-agent path; cloud deploy and recovery | Keep using one reproducible Ubuntu VM now. Plan the rack, power, switch and cabling; add a dedicated Linux workstation when feasible. No separate server required. | Recreate a VM, independently diagnose an access or service failure, reproduce relevant app steps; demonstrate the portfolio's real T1–T5 outcomes as completed, not planned. |
| **Q1 2027** — isolated virtualization | Operate and restore guests without interrupting daily development | Use workstation KVM/libvirt first. Add a separate x86 hypervisor host (Proxmox VE candidate) *only if* resource use or fault-isolation experiments justify it. | Rebuild a test guest from recorded inputs, restore a synthetic dataset, document and repeat a failure/recovery cycle. Continue January applications. |
| **Q2 2027** — container orchestration | Deploy, observe and troubleshoot a service in Kubernetes | Start with local Kubernetes, then multiple VMs on existing hardware; deploy an **isolated** finance-lab test environment, not an unplanned production migration. | Explain resource requests/limits, probes, networking, storage, safe rollout and rollback; reproduce a failed workload diagnosis. |
| **Q3 2027** — SRE and distributed failure | Set measurable reliability targets and run controlled failure drills | Add observability, backup/recovery and capacity tests. A second physical compute node is optional **only** for a verified cross-host failure or availability scenario. | Show incident timeline, metric/log/trace evidence, recovery measurements, data-recovery test, and limitations. Multiple VMs on one server are not physical HA. |
| **Q4 2027** — agent infrastructure | Operate bounded agent workloads with isolation, evaluation and cost/reliability controls | Exercise timeouts, concurrency caps, tool authorization, telemetry, regressions, teardown and isolated execution. Optional local-model comparison; GPU only if benchmarked need warrants it. | Demonstrate that a malformed/unauthorized or resource-exhausting agent task is contained, observed, and recoverable without affecting personal/work devices. |

Dates are **review points**, not forced completion deadlines. If a milestone
slips, narrow scope instead of adding hardware or another course by default.

## Near-term execution (October 2026 – January 2027)

- **October:** continue VM/SSH/files/users/processes/networking exercises and
  the first real Python-to-model call. Capture rack/port constraints without
  waiting for purchase. In parallel, keep the portfolio's T2 cloud planner
  (authenticated users, persistence, safe API boundaries) on its existing path.
- **November:** practise Linux and container diagnostics on the actual
  finance-lab services; implement the controlled agent and approval boundary
  in the appropriate application repositories, not in `linux-lab`.
- **December:** use disposable local/cloud environments for Terraform,
  image-version deployment, telemetry, rollback and recovery; produce
  explainable interview evidence. Preserve identity, authorization, approval,
  regression and operational safety tests when cutting scope.
- **January 4–15:** begin role applications using **actual evidence** even
  if the physical lab is incomplete. Keep applying and learning in parallel.

These are *intended* outcomes from the career baseline, not a progress report.

## Hardware expansion requires a trigger

| Proposed purchase | Decision trigger | Not a sufficient justification |
| --- | --- | --- |
| Rack, rails, shelving, power accessories | Measured dimensions/load, acceptable noise/ventilation, safe power and cable paths; room for existing systems and gradual additions | Wanting a professional-looking full rack |
| Managed switch | More Ethernet ports needed and a verified safe topology; VLAN needs understood | Expecting a faster internet connection through the KN-1711 uplink |
| Linux workstation | Development/VM practice is constrained by current setup and moving development off the Mac adds measurable value | Assuming an expensive GPU is needed for ordinary Linux/AgentOps learning |
| Dedicated hypervisor server | Workstation VM resource contention or deliberate independent reset/failure drills | Kubernetes with a few VMs by itself |
| Second physical compute node | A test requiring independent physical failure domains that cannot be reproduced on one machine | Labelling a single-host virtual cluster as HA |
| NAS / backup appliance | Validated recovery, retention/capacity or host-loss requirements that simple independent copies cannot meet | Treating a NAS as a backup without an additional copy |
| AI GPU node | Defined model + workload, memory requirement, latency/throughput target, power/cost comparison and measured API/local constraints | Wanting to "learn AI" in general |

Before buying: write down the experiment, current bottleneck, a no-purchase
alternative, expected power/noise/storage impact, and success criteria. Check
availability and total landed cost at the time of purchase, not from an old
wish list.

## Competence checkpoints toward the end of 2027

Aspirational "senior-level" progression should be evaluated through **independent
engineering judgement**, not number of servers, tools or certificates:

1. **Design:** elicit requirements; explain interfaces, boundaries, trade-offs,
   failure modes, and why simpler approaches may be preferable.
2. **Operation:** deploy and roll back a known revision; recover from a
   reproducible incident with real telemetry and tested backup procedures.
3. **Security/AgentOps:** prove least privilege, human approval where needed,
   idempotency, bounded agent execution, deterministic evaluations and cost limits.
4. **Knowledge transfer:** create a concise runbook another engineer can
   follow; justify choices under review; record unknowns and measured limits.

A homelab cannot substitute for production ownership, collaboration and
organizational impact. The level attained at work remains employer-specific.

## Repo responsibilities and safety

- `linux-lab`: physical/logical lab overview, guest configuration,
  disposable exercises, sanitized recovery evidence.
- `finance-lab` / `finance-lab-agent`: product runtime and agent behavior.
- `finance-lab-platform` (when present): real deployment, IaC, telemetry
  configuration and operational procedures for the portfolio.
- `career`: interview/application planning; do not duplicate sensitive
  personal career details in this public repository.

Follow [AGENTS.md](../../AGENTS.md): no secrets or employer data in Git,
no unapproved cloud spend, no automatic merge, and no claim of skill from an
AI-authored artifact without Anton's own demonstration.

