---
description: Start work on a Jira ticket — readiness gate, branch per the branch naming convention, and always asks whether to branch off develop or an active sprint branch. Hands over to the lifecycle plugin, if configured.
argument-hint: "<TICKET-KEY>"
allowed-tools: Bash(git status:*), Bash(git fetch:*), Bash(git branch:*), Bash(git log:*), Bash(git rev-parse:*), Bash(git for-each-ref:*)
---

# /start-branch

Ticket: `$ARGUMENTS`

A lifecycle plugin's `dev-lifecycle` typically works on the current branch but doesn't create one. This command fills that gap with your conventions, then hands over.

Use **fe-standards**: `references/jira-conventions.md` (Branches), `references/dor-dod.md`, `references/agent-docs.md`.

## 1 — Readiness gate

1. `getJiraIssue` (`*all`, comments, issue links).
2. Existing `[dev-note:refinement]` → use its DoR score and check which open questions have been answered in comments since. None → quick DoR score now.
3. Linked `is blocked by` / `depends on` issues not Done → report as blockers.
4. Ready → continue. Partly ready / Not refined / blocked → show the open points and ask: "Start anyway, run `/dev-frontend:refine-ticket` first, or send the questions first?" Don't continue on your own.

## 2 — Branch

1. `git status --porcelain` not clean → stop, list the files.
2. `git fetch --prune`.
3. Determine type (Story/Task/Sub-task → feature, Bug → bug, Support → support) and propose the name per the table. Bug → propose `<short-description>`, and note the ticket key belongs in every commit message.
4. Branch exists locally or remotely → offer `git switch` instead of creating a new one.
5. **Ask the base branch — always**, even with one candidate: list base candidates + matching sprint branches with last-commit dates. Hint the ticket's sprint if it matches a branch; never decide.
6. After choice and approval: `git switch -c <branch> origin/<base>`.
7. Remember the chosen base: tell the user to pass it to lifecycle skills that take one (e.g. `/<lifecycle>:branch-review <base>`).

## 3 — Optional

Ask separately, act only on yes:
- Move the ticket to *In Progress* (`getTransitionsForJiraIssue` → `transitionJiraIssue`).

## Hand-over

End with one line:
> Next: `/<lifecycle>:dev-lifecycle <KEY>` (plan → implement → QA → review). Run `/dev-frontend:fe-gate <KEY>` after the review phase.

If no lifecycle plugin is configured, suggest `/dev-frontend:test-scenarios` and `/dev-frontend:fe-gate` after implementing instead.
