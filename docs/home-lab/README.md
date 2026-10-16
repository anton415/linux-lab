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
| Employer-managed PC | Work only. **No experiments**, configuration changes, or lab dependencies. Case dimensions reported as **310 × 100 × 340 mm** (axis orientation/cable clearance not yet verified). |
| Keenetic Extra KN-1711 | Existing home router; two Keenetic Air units and the two PCs use its four available wired LAN connections. |
| Keenetic Air × 2 | Existing devices in other rooms; their operating modes and detailed configuration are not documented here. |
| ATEN DisplayPort KVM | Owned; suitability for future video connections remains to be verified. |
| `linux-lab` repository | Existing scripts and instructions for a small Linux VM; a successful boot and independent demonstration are not assumed. |

Nothing above asserts that a rack, Ethernet switch, Linux development PC,
hypervisor server, backup appliance, or GPU node has been purchased.

## Rack form-factor and aesthetic priorities (user-reported 2026-10-16)

Approximate available **width: 1,000 mm** and **height: 2,400 mm**.
An **800 mm-deep cabinet plus a 100–150 mm rear cable gap** is acceptable
(900–950 mm total depth). This does **not** confirm rear-door swing or
service access. These are coarse planning limits, not verified clearances.
The rack will be in a multipurpose living/working space where **quiet
operation, heat, stability, and electrical safety** are essential.

This is intended to be a **premium, professional-looking, long-lived centerpiece
for 5+ years of incremental growth**. A **gray powder-coated
enclosure is explicitly acceptable**, while white is optional; retain
a **tempered-glass front**, high-quality cable management and
thoughtful accessories. These priorities replace an earlier 18–24U
price/compactness-first assumption.

**Provisional target (not yet a SKU or purchase approval): 42U × 600 mm
wide × 800 mm deep**, with exact external dimensions/clearances to be
confirmed. A 47–48U option is not automatically better merely because
room height is available. See the [rack design brief](rack-design.md).

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

See the [selected physical network topology](network.md),
[long-term rack design brief](rack-design.md), and
[phased roadmap](roadmap.md) through 2027.

## Open decisions — do not treat as approved

- Exact **42U cabinet model** (currently Cabeus is the visual favorite;
  cheaper ExeGate and mid-range ЦМО remain candidates), usable depth,
  supported shelf/rail layout, rear-door access beyond the confirmed
  100–150 mm gap, anti-tip/floor loading, ventilation and acceptable
  nighttime noise. Gray is acceptable; **no model is purchased or approved**.
- Physical case dimensions were reported, but **orientation, ventilation,
  safe shelf fit, plug clearance and permitted placement of the work PC**
  still need confirmation; no employer-machine modification is planned.
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

