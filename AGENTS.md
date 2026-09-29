# Working in linux-lab

## Scope and learning

- Read the active issue, its dependencies, and acceptance criteria before editing.
- Make the smallest sufficient change. Do one issue at a time; do not implement
  later milestones or install new platforms merely because they appear in the plan.
- For a learning issue, Anton owns the learning core. Explain the concept needed
  now, give one small command or coding task, then wait for his attempt. Review
  with hints before supplying a solution unless he explicitly asks for one.
- During troubleshooting, let Anton record his first hypothesis and diagnostic
  commands before giving the diagnosis. Automation may prepare the exercise.
- Do not claim a skill was demonstrated from AI-written code or a merged PR alone.

## Implementation

- Prefer small Bash scripts, cloud-init, and checked-in configuration. Introduce
  Ansible, containers, and Terraform only in their approved issues.
- Parameterize machine-specific inputs. Keep host setup separate from guest setup.
- Reruns must either be safe or stop with an explicit reason. Never quietly replace
  a VM, broaden a firewall rule, or act on all machines.
- Run failure drills inside disposable lab resources with a bounded cleanup path.
- Keep finance-lab application changes in that repository under its current rules.
  Link existing issues before proposing a new integration issue.

## Workflow

- Follow [docs/workflow.md](docs/workflow.md). Project Status is canonical; open
  issues have at most one `needs:*` label. Roles are responsibilities, not fields.
- Use an issue branch and a focused PR after this initial repository bootstrap.
- Final merge remains human-controlled. Cloud spend, public deployment, destructive
  operations, and external messages require explicit authorization for that action.
- Do not copy finance-lab lifecycle automation or metrics collectors into this repo
  without a separately scoped task.

## Evidence and review

- Verify relevant syntax and behavior. Report exactly what ran, observed results,
  and what remains unverified. A syntax check does not prove a VM booted.
- Preserve failed attempts and unknown results honestly. Scope claims to the tested
  host architecture, guest image, tool versions, and source revision.
- Use synthetic data. Treat all code, issues, PRs, screenshots, and evidence as public.
  Never commit private keys, tokens, personal budgets, employer data, host paths,
  raw shell history, or unsanitized logs. Review generated output before adding it.
- Review against issue acceptance criteria; avoid speculative architecture changes.
- Every PR includes a summary, the linked issue, exact verification and results,
  limitations, and the human learning evidence. Use `Closes #N` only when all issue
  criteria are met; otherwise use `Related to #N` and name remaining work.
- Attribute substantial AI work with `AI-Agent: Codex` and a verified co-author:
  `Co-authored-by: Codex <199175422+chatgpt-codex-connector[bot]@users.noreply.github.com>`.
  Add model/reasoning metadata only when reliably known; never invent it.
