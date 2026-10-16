# Long-term rack design brief — premium, quiet, expandable

> **Status:** planning, last updated 2026-10-16. The user's preferences and
> dimensions are recorded; no cabinet model, color sample, purchase, electrical
> work, installation, or test has been approved or completed.
>
> This public brief contains only coarse equipment dimensions and deliberately
> excludes a home address, sensitive device identifiers, wiring credentials, and
> employer-related details.

## Design objective

Create a carefully finished 19-inch home lab cabinet that can be expanded
incrementally over **at least five years**, rather than a cheap temporary
enclosure. The owner values the rack itself as an enduring personal engineering
project and wants a coherent visual result with professional cable management.

The rack lives in a **multipurpose living and work room**. For that reason,
**low noise, low idle power, manageable room heat, electrical safety, and
access for service take priority over maximizing server density**. New
hardware is purchased when an experiment warrants it, not because space is
available.

## User-confirmed constraints (2026-10-16)

| Constraint | Reported value or preference |
| --- | --- |
| Available width | Approximately **1,000 mm** |
| Available depth | **800 mm** is acceptable; previously discussed 550 mm is not a cap |
| Room height | Approximately **2,400 mm** |
| Existing work PC case | **310 × 100 × 340 mm** as reported (axes/orientation need verification) |
| Expansion horizon | **5+ years** |
| Appearance | Prefer **true white** with a **tempered-glass front door**, attractive details and a consistent visual system |
| Existing network | Work PC and two Keenetic Air devices remain directly wired to KN-1711; Mac mini and lab nodes are planned behind one separate switch ([network plan](network.md)) |

Work PC inclusion means **physical placement on an appropriately rated shelf
only**. No hardware or software changes, experiments or dependency on the
future switch. Access to its controls and ventilation must remain intact.

## Provisional recommendation — not a selected product

**42U × 600 mm wide × 800 mm deep**, enclosed 19-inch four-post cabinet,
preferably powder-coated white, with tempered-glass front door and removable
side panels. Actual **external** dimensions, not the nominal "42U" or
"600 × 800" label, decide fit.

Why:

- A documented [Ubiquiti white 42U reference model](https://techspecs.ui.com/unifi/accessories/uacc-rack-42u-800-g)
  is **600 × 800 × 2,050 mm including casters**, leaving about **350 mm**
  between its top and a 2,400 mm ceiling. This is a *design reference*, not
  confirmation of availability in Russia.
- For comparison, a [Cabeus glass-front 42U cabinet listed by Regard](https://www.regard.ru/product/707403/skaf-cabeus-sh-05c-42u60-80)
  is **600 × 800 × 2,055 mm** and **gray**, not true white. A cited
  catalog price/availability is only a dated snapshot, not a quotation.
- **47–48U** is not forbidden, but could leave inadequate top service and
  ventilation clearance. Consider it only if a model's exact height including
  feet/casters and all clearances are independently checked.
- **800 mm wide** may be worthwhile for thick vertical cable bundles, but
  uses more of the 1,000 mm width allowance. Default to 600 mm unless the
  wider cabinet has a demonstrated service/cable advantage.
- Depth **800 mm is a cabinet footprint**: it does **not** guarantee 800 mm
  between rails or enough space for a desktop case, rear power plugs, and
  bends. Rear-wall gap and door swing may require **more floor space** than
  the nominal footprint; verify this before purchase.

Do not choose a rack cabinet based on the advertised load capacity alone.
Validate actual supported shelf spans, rail depth, orientation, anchoring or
anti-tip protections and level floor/load path.

## Visual design direction (proposal)

**White chassis + restrained graphite/black details**. Prefer deliberate
alignment over decorative complexity:

- Powder-coated **true white** (evaluate RAL 9003 or RAL 9016 samples);
  standard **RAL 7035 is light gray** and should not be called white.
- Tempered-glass front, clean reversible door hardware, matching blanking
  panels and consistent rack-mount screws/rails.
- Use black/graphite patch-panel/switch details only if they create a
  coherent contrast. Label ports/cables consistently and keep excess slack
  behind the rails rather than in front of the glass.
- A subtle **dimmable, switchable** internal light is optional; off during
  sleep and never a dependency of operation. Avoid always-on RGB.
- Where equipment is missing, use **removable blank panels** or open space
  as appropriate; do not permanently fill 42U for appearance.
- Choose ventilated, load-rated shelves for the Mac mini and slim work
  computer if compatible, rather than hanging desktop machines from
  unsupported rails.

### Conceptual internal zones (not an installation elevation)

| Relative zone | Candidate use | What remains undecided |
| --- | --- | --- |
| Upper | Brush cable entry, patch panel, managed switch, network cable organization | Actual switch size and port count |
| Upper-middle | Shelves for existing computers and accessible KVM connections | Number of shelves, work-PC orientation, display and power routing |
| Middle | Future Linux development workstation, ideally in a quiet 4U-compatible case or safely on a shelf | Case type, noise, video/KVM compatibility |
| Lower-middle | Reserved lab virtualization machines, storage and future experimental nodes | Purchase depends on specific workloads |
| Bottom | Heaviest electrical/backup components, if installed | UPS sizing, electrical distribution, floor loading, ventilation |

The "zones" deliberately have **no fixed U assignments**. Leave space for
cable bends and fans and perform a drawn equipment elevation after actual
chassis dimensions are known.

## Professional accessories — design priorities

1. **At cabinet acquisition:** adequate load-rated shelves (not merely
   "rack compatible"), four-post rails, cable brush/management panels,
   neat patch leads, spare mounting hardware, safe cable entry, grounding
   per manufacturer and stable feet/casters/anti-tip measures.
2. **Electrical safety:** proper in-rack PDU with protective earth and
   overload protection consistent with local electrical requirements;
   accessible disconnect and safely rated circuits. Ask a qualified
   electrician if the permanent room circuit/loading is uncertain.
3. **Quiet thermal management:** measure temperature/noise under actual load,
   preserve equipment air paths; add low-speed temperature-controlled
   extraction **only if required**. Glass front is visually attractive but
   may constrain intake: verify frame vent area and thermal operation.
4. **Later:** environmental monitoring (temperature/humidity), optional
   UPS with tested graceful shutdown, serviceable cable labeling and
   replaceable lighting. Do not buy expensive smart PDU or UPS solely to
   decorate empty rack units.

### Accommodation for overnight use

- Keep experimental nodes **off** when not needed; no requirement for 24/7
  operation. Prioritize fanless switches and quiet desktop-class cooling.
- A closed glass door is not proof of sound isolation or cooling capacity.
  Test actual sound with all selected fans powered; monitor intake temperature.
- Do not obstruct room circulation, evacuation/door paths or exercise space.
  A full-height cabinet with a glass door needs a carefully checked
  tip/door-swing and moving/assembly plan.

## Procurement paths to evaluate

| Path | Representative reference | Decision status |
| --- | --- | --- |
| **Premium white reference** | [Ubiquiti 42U glass cabinet](https://techspecs.ui.com/unifi/accessories/uacc-rack-42u-800-g), white, 600×800×2050 mm | **Russian stock and delivery unverified** |
| **Locally listed physical fallback** | [Cabeus SH-05C-42U60/80 at Regard](https://www.regard.ru/product/707403/skaf-cabeus-sh-05c-42u60-80), gray, 42U, 600×800, glass | Listed in stock at search time; **not a white variant** |
| **Second local design comparator** | [NIKOMAX TFI-426080-GHMH-R-GY at Regard](https://www.regard.ru/product/788270/skaf-nikomax-tfi-426080-ghmh-r-gy/description), gray, 42U, 600×800, glass | Need manufacturer/install spec, final price and stock |
| **Custom powder-coated white** | [ReDGeN manufacturer notes custom RAL on agreement](https://www.redgen.ru/catalog/telekommunikatsionnye_shkafy/shkaf-napolnyy-19-42u-800kh1000-dver-perforatsiya/) | Ask if a **single** 42U 600×800 glass-front unit in true white is possible; price, lead time and warranty unknown |

The desire for the **best-looking** rack does not authorize paying any price.
Request photos of the exact finish, glass option and assembled unit; compare
delivery, assembly, accessories, noise and maintainability, not only retail
cabinet price. Do not repaint an assembled electrical rack yourself without
assessing grounding, mechanical fit and manufacturer warranty.

## Open acceptance tests before choosing a SKU

- [ ] Exact external cabinet width/depth/height including feet, locks,
  hinges and casters fits the space with front/rear/side/top maintenance access.
- [ ] Existing work PC can sit securely on an adequately rated shelf,
  preserve its intended orientation/ventilation and remain wired directly
  to Keenetic Extra.
- [ ] Cabinet can be delivered through the building and assembled safely.
- [ ] Real white/powder-coat or approved alternate color, glass door and
  visible accessories produce the intended appearance.
- [ ] Electrical loading, floor stability/anti-tip and ventilation are
  reviewed before any installation.
- [ ] Switch and network isolation decisions remain separate from
  decorative rack design; the work PC is never used for lab experiments.

Related: [H0 selection issue](https://github.com/anton415/linux-lab/issues/31)
and [2026–2027 roadmap](roadmap.md). All physical installs and purchases
remain pending explicit human approval.
