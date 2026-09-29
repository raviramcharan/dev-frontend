---
description: Mirror lifecycle and dev-frontend artefacts (plan, testplan, test scenarios, FE gate, docs, refinement) into the Jira ticket as developer notes — updating existing notes instead of duplicating, preserving human-entered results.
argument-hint: "[<TICKET-KEY>] [plan|testplan|test-scenarios|fe-gate|docs|all] [--full] [--lang nl|en]"
---

# /jira-sync

Arguments: `$ARGUMENTS`

Lifecycle plugins keep artefacts in `agent_docs/` and usually leave "posting results back to Jira" to the user. PO, testers and QA work in Jira. This command closes that gap. `agent_docs/` stays the source of truth; Jira notes are a mirror.

Use **fe-standards**: `references/jira-conventions.md` (developer notes), `references/agent-docs.md`, `references/output-language.md`.

## 1 — Resolve

- Key and `<DOCS>` per fe-standards / `agent-docs.md`.
- Artefact(s): the argument, or `all`. Without an argument → list what exists and ask which to sync.

| Artefact | Source | Note tag | Visibility |
|---|---|---|---|
| plan | `<DOCS>/plan.md` (newest `phases/*.md` noted) | `plan` | `devNote.visibility` |
| testplan | `<DOCS>/testplan.md` | `testplan` | `devNote.visibility` |
| test-scenarios | `<DOCS>/test-scenarios.md`, or the latest `/test-scenarios` output in this conversation | `test-scenarios` | `privateVisibility` → fallback `visibility` |
| fe-gate | `<DOCS>/fe-gate.md` | `fe-gate` | `devNote.visibility` |
| docs | `<DOCS>/docs.md` | `docs` | `devNote.visibility` |

Missing source → say which, skip it, continue with the rest.

## 2 — Shape the content

- **plan** (default: summary, `--full` for everything): goal & scope, acceptance criteria table (AC1…), out of scope, milestone titles only, decisions from grilling if present. Audience: PO and team — no file-level detail unless `--full`.
- **testplan / test-scenarios / fe-gate / docs**: as-is (already human-readable), unless longer than ~25,000 characters → summary + path.
- **Staleness:** for `fe-gate`, compare its `code=` in `.fe-checks.log` with the current `CODE_SHA`. Stale → warn and suggest re-running `/dev-frontend:fe-gate` before syncing; sync only if the user insists, and mark it "outdated since <sha>" in the note.
- Wrap in the developer note format; `<sources>` names the file path and `CODE_SHA`.

## 3 — Preview and post

Per artefact:
1. Look up an existing note with the same tag.
2. Show: new note, or diff against the existing one. For test-scenarios, **keep result markers and remarks the user filled in** in the existing note.
3. Ask per artefact: post / update / skip. One approval covers one note.
4. After posting, append `check=jira-sync status=pass note=<artefacts>` to `<DOCS>/.fe-checks.log` (only if `<DOCS>` exists).

## Never

- Write into the description (that's `/refine-ticket --apply`).
- Post anything with public visibility.
- Modify files in `agent_docs/` owned by the lifecycle plugin.
