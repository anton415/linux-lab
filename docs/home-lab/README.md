# Home lab — architecture baseline

> **Status:** planning record, 2026-10-16. **No hardware purchases, rack
> installation, network changes, or completed learning milestones are implied.**
> This public document deliberately omits IP addresses, SSIDs, credentials,
> detailed physical location, and employer-sensitive information.

## Purpose and constraints

Build a home lab incrementally to support Linux, networking, backend/platform
engineering, reliability, and safe AI-agent execution. Prefer reproducible
experiments with a failure and recovery exercise over accumulating hardware.

The home lab **supports** the existing finance-lab portfolio; it is not a
separate prerequisite for January 2027 job applications. The frozen
[October 2026–January 2027 career plan](https://github.com/anton415/career/blob/main/planning/agentops-transition-plan-oct2026-jan2027.md)
remains authoritative for portfolio priorities and application dates (the career
repository may require private access). The broader ambition is to grow toward
senior-level engineering capability by the end of 2027; owning more hardware
does not establish a senior level.

## As-Is — user-reported equipment

| Item | Current role / fact |
| --- | --- |
| Mac mini M4 Pro | Personal daily computer; stays in the Apple ecosystem. |
| Employer-managed PC | Work only. **No experiments**, configuration changes, or lab dependencies. |
| Keenetic Extra KN-1711 | Existing home router; two Keenetic Air units and the two PCs use its four available wired LAN connections. |
| Keenetic Air × 2 | Existing devices in other rooms; their operating modes and detailed configuration are not documented here. |
| ATEN DisplayPort KVM | Owned; suitability for future video connections remains to be verified. |
| `linux-lab` repository | Existing scripts and instructions for a small Linux VM; a successful boot and independent demonstration are not assumed. |

Nothing above asserts that a rack, Ethernet switch, Linux development PC,
hypervisor server, backup appliance, or GPU node has been purchased.

## Selected network decision — planned, not implemented

**Decision confirmed 2026-10-16:** both Keenetic Air devices and the work PC
stay directly connected to Keenetic Extra. The Mac mini's existing Extra LAN
port becomes the **single switch uplink**; connect Mac mini and future lab
machines behind the switch. Extra still has four occupied LAN ports. The work
PC remains outside lab experiments and does not depend on switch uptime.

This is an **approved design direction**, not approval to buy a switch or
change any live cabling. See the [selected physical diagram](network.md).
A dedicated firewall/VLAN design, switch selection and actual installation
remain pending.

## Proposed — eventual component roles

| Component | Intended responsibility | Acquisition/implementation |
| --- | --- | --- |
| 19-inch rack or suitable cabinet | Organize existing machines, cabling, networking, and later equipment | **Pending** physical measurement, power, noise, ventilation, and cost review |
| Managed Ethernet switch | Fan out a single Extra LAN connection to multiple nearby devices; provide a later path to VLANs | **Pending** model and network design |
| Dedicated Linux workstation | Development, terminal, KVM/libvirt VMs, containers, recovery tools | **Pending** selection and purchase |
| Separate virtualization server | Disposable guests and failure experiments independent of the development workstation | **Conditional**, not required before January |
| Backup destination | Keep recoverable copies outside the primary host; periodically test restores | **Pending** retention and off-host design |
| Additional physical node | Learn genuine physical-node outages or expand capacity | **Conditional** on a measured use case |
| AI/GPU computer | Local inference under measurable model, memory, latency, and cost requirements | **Optional**; not a default AgentOps requirement |

Keep the Mac personal; move **development and experiments**, not the whole
personal workflow, to Linux. Existing home internet and the work PC must not
depend on the lab being healthy. A shared router and power feed are still
common dependencies; this is not a claim of full isolation.

## Architecture principles

1. **Home must survive a lab failure.** Keep risky guests and lab networking
   separate from critical daily equipment; test rollback before replacing
   routing or switches.
2. **Understand before automating.** Reproduce a manual setup and diagnose
   the first meaningful failure, then capture repeatable configuration.
3. **Infrastructure follows a need.** A server, extra node, faster switch,
   Kubernetes, and local GPU each need a demonstrated limitation or experiment.
4. **Do not make a rack a blocker.** Start or continue the existing VM and
   finance-lab tasks on available equipment even if purchases take longer.
5. **One scoped change at a time.** The current [learning issues](../learning-plan.md)
   remain their own acceptance gates; this planning document closes none of them.
6. **Public-by-default documentation.** Never commit router exports, hostnames,
   addresses, secrets, account data, employer information, or raw network captures.

See [physical network topology](network.md) for As-Is and proposed cabling
options and the [phased roadmap](roadmap.md) for learning outcomes through 2027.

## Open decisions — do not treat as approved

- Rack location, internal usable depth, suitable mounting/rail layout, weight,
  ventilation and acceptable noise. A 24–32U format has been *discussed*, not chosen.
- Physical size and permitted placement of the work PC; no employer-machine
  modification is part of this plan.
- Switch port count (8–16 is a candidate), managed/VLAN feature set, uplink
  speeds, placement and cable route. **Work PC direct wiring is decided**.
- Gateway/firewall and VLAN routing design; a switch alone is not a security
  boundary for all traffic.
- Linux workstation CPU/RAM/storage specification, actual VM capacity, backup
  policy, power protection, and total cost/power budget.
- Compatibility with the existing DisplayPort KVM and future display outputs.

After each decision, update **As-Is**, **Proposed**, and **Pending** explicitly.
Record dated evidence for actual builds in the appropriate `labs/` or
`evidence/` paths, not as unverified claims in this document.

