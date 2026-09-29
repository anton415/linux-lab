# Applying Linux to finance-lab

## Inspected baseline

On 2026-09-29, reviewed all 71 finance-lab issues returned by the issue inventory,
all eight milestones, the workflow contract, contribution rules, README, package
scripts, CI, and the relevant M5/M6 issue bodies. Source snapshot:
[`e28140d5eb713f3aa022ca6e8fbdb9210b5ba4f1`](https://github.com/anton415/finance-lab/tree/e28140d5eb713f3aa022ca6e8fbdb9210b5ba4f1).
Recheck current scope and state before starting an integration task.

The application is a React/TypeScript/Vite static frontend. CI uses Node 24 and
Python 3.12. There is no current Java service or required application database.
`npm run build` produces `dist/`; use a static server for operational practice.
[Vite documents](https://vite.dev/guide/static-deploy) that `vite preview` is for
local preview, not a production server.

## Ownership and dependency map

| Existing finance-lab work | Snapshot state | Linux contribution | Boundary |
|---|---|---|---|
| [#47 budget model](https://github.com/anton415/finance-lab/issues/47), [#48 category summary](https://github.com/anton415/finance-lab/issues/48) | #47 closed; #48 open | Build an exact reviewed revision and smoke-test synthetic data | Do not change the model or category UI for an operations lab |
| [#54 release artifacts](https://github.com/anton415/finance-lab/issues/54) | Open, draft | L2.1 proves a clean Linux build and records source/toolchain/artifact identity | Release tags and release policy remain in #54 |
| [#55 static demo](https://github.com/anton415/finance-lab/issues/55) | Open, draft | L2.3 serves the built frontend through local Nginx | Public hosting and domain decisions remain in #55 |
| [#56 verification/rollback](https://github.com/anton415/finance-lab/issues/56) | Open, draft | L3.1 restores synthetic exports; L3.3 repeats local provisioning | Release rollback acceptance stays in #56; no automatic closure |
| [#62 API](https://github.com/anton415/finance-lab/issues/62), [#63 persistence](https://github.com/anton415/finance-lab/issues/63), [#64 retries](https://github.com/anton415/finance-lab/issues/64), [#65 limits/recovery](https://github.com/anton415/finance-lab/issues/65) | Open, drafts | L6.1 operates the actual approved service when available | Do not create a competing runner, job store, API, or retry engine |
| [#66 operational objective/runbook](https://github.com/anton415/finance-lab/issues/66) | Open, draft | L6.2 supplies bounded Linux diagnosis and measured evidence | The application objective and reporting definition remain in #66 |
| [#81 workflow](https://github.com/anton415/finance-lab/issues/81), [#94 lifecycle reconciliation](https://github.com/anton415/finance-lab/issues/94), [#95 review handoff](https://github.com/anton415/finance-lab/issues/95) | #81/#94 closed; #95 open | Reuse the status/label contract manually | Do not duplicate or change lifecycle automation as part of this setup |

M1–M3 and AgentOps milestones are closed; M4–M7 remain open. Closed learning or
evaluation issues do not by themselves establish that a runnable service exists.
L6 is explicitly blocked until the relevant finance-lab functionality is approved
and delivered. Earlier Linux milestones can proceed independently of those drafts.

## Concrete handoffs

- Keep generic Linux scripts, VM definitions, fault drills, and local lab evidence
  here. Refer to finance-lab by repository URL and exact commit; do not vendor it.
- If a reusable app-specific deployment/build/runbook change is warranted, first
  refine the corresponding existing finance-lab issue. Open its PR in finance-lab,
  link the Linux evidence, and follow that repository's checks and review rules.
- A lab experiment is evidence for that issue, not proof that all product criteria
  are done. Cross-repository links should use `Related to`, not accidental closure.
- This initial setup creates Linux issues only. It does not change finance-lab code,
  issues, milestones, hosting, secrets, or automation.

## Build exercise inputs

At L2.1 select a reviewed finance-lab commit, clone it in the guest, and record
`git rev-parse HEAD`. Match its CI toolchain and use its lockfile. The inspected
checks are `npm ci`, `npm run lint`, `npm test`, `npm run test:coverage`,
`npm run test:metrics`, `npm run build`, and the Python workflow test command in CI.
Re-read the actual CI at the selected revision; do not copy upload tokens to the VM.

Use a clean browser profile and synthetic data for smoke checks. Serving `dist/`
does not move browser storage onto the VM. Archive an intentionally exported
synthetic JSON backup for recovery practice; check the current backup contract
before restoring it. Restoring server files and restoring browser data are distinct
operations, as are code rollback and data compatibility.
