# Workflow and learning ownership

The contract follows [finance-lab #81](https://github.com/anton415/finance-lab/issues/81),
verified on 2026-09-29. Older issue prose mentioning a `Next actor` field is stale.
Project **Status** answers where work is; one `needs:*` label answers what is needed.

| Situation | Status | Next-work label | Responsibility |
|---|---|---|---|
| Idea needs refinement | Backlog | `needs:spec` | Analysis / ChatGPT drafts a small specification |
| Specification accepted | Ready | `needs:implementation` | Human selects the next exercise |
| Work or a draft PR starts | In progress | Clear the implementation label | Human writes the learning core; Implementor / Codex assists |
| Implementation ready | Review | `needs:review` | Code review and acceptance/evidence review |
| Review accepted | Review | `needs:human` | Human demonstrates learning and makes the final merge decision |
| Changes requested | In progress | `needs:implementation` | Assigned implementer fixes the specific finding |
| All criteria and learning evidence accepted | Done | Clear all `needs:*` labels | Human accepts completion; merge where applicable |

An open issue has at most one `needs:*` label. Blocked/deferred issues may have none.
`learning` and `finance-lab` are descriptive labels, not lifecycle states. A PR
closed without merging does not automatically complete or reset the issue.

## Roles

- **Human / Anton:** chooses scope and sequence; performs the learning core and
  initial diagnosis; approves risky actions and final merge; explains the outcome.
- **Analysis / ChatGPT:** refines the next issue, identifies dependencies and
  acceptance evidence, and gives focused teaching prompts.
- **Implementor / Codex:** prepares approved scaffolding, assists with configuration
  and checks, reviews Anton's attempts, and implements only explicitly delegated work.

Do not automatically start agents, merge PRs, or publish deployments. This repository
starts with manual status/label updates. Finance-lab automation remains scoped to
finance-lab; compatible workflow does not imply automation was installed here.

## Working an issue

1. Pick the first unblocked item. Refine any draft assumptions before setting Ready.
2. State the single small step Anton will perform. Use `man`, help, and logs first.
3. Put configuration and scripts in `labs/<topic>/`; put reviewed observations in
   `evidence/<issue-number>-<topic>.md` using the template.
4. Open a focused PR. Record exact checks and failures, including expected failures.
5. Code review comes before human acceptance. Use `Related to #N` while the human
   demonstration is missing so a merge does not prematurely close the learning issue.
6. Close only when artifacts, recreation instructions, evidence, and Anton's
   explanation satisfy the issue. Then select the next issue separately.

## Shared project

Use [Finance Lab Development](https://github.com/users/anton415/projects/9), filtered
by `repo:anton415/linux-lab`. The existing Status options already match this contract.
Keep its schema and finance-lab items unchanged. Dependencies are explicit links
in issue bodies; a Backlog item does not authorize implementation.

Suggested rhythm: two short concept/practice sessions and one troubleshooting
session each week. Milestones have outcome gates, not committed dates. Split an
issue if a single step needs more than a focused session.
