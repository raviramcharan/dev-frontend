# Working alongside a lifecycle plugin

A lifecycle plugin (`lifecyclePlugin` in config, see SKILL.md) is installed separately. This plugin **reads** its `agent_docs/` artefacts; it never modifies them and never copies its skills.

## Is it installed?

Resolve `lifecyclePlugin` first (SKILL.md → *Resolving `lifecyclePlugin`*: absent → detect and ask, `null` → standalone, namespace → use). Standalone: every dev-frontend command still works; skip the steps that read lifecycle artefacts and say so in one line.

## Resolve `<DOCS>` — canonical probe

```bash
ROOT=$(git rev-parse --show-toplevel) || exit
[ -z "$KEY" ] && { echo "No Jira key resolved — ask the user before probing."; exit; }

DOCS=$(ls -dt "$ROOT/agent_docs"/sprint-*/"$KEY" 2>/dev/null | head -1)              # 1. sprint layout
[ -z "$DOCS" ] && [ -d "$ROOT/agent_docs/$KEY" ] && DOCS="$ROOT/agent_docs/$KEY"     # 2. flat layout
[ -z "$DOCS" ] && DOCS=$(ls -dt "$ROOT/agent_docs"/*/"$KEY" 2>/dev/null | head -1)   # 3. other parent
```

Never create a `<DOCS>` directory yourself — `/<lifecycle>:jira-plan` decides the layout. If `<DOCS>` doesn't exist and you need to write a file, ask the user first and use the flat layout `agent_docs/<KEY>/`.

## Artefacts

| File | Owner | dev-frontend use |
|---|---|---|
| `<DOCS>/issue.md` | lifecycle (hand-curated) | Authoritative ticket content if present — prefer over a live fetch |
| `<DOCS>/plan.md`, `<DOCS>/phases/*.md` | `jira-plan`, `phase-plan` | Read: AC (AC1…), scope, milestones |
| `<DOCS>/testplan.md` | `testplan` | Read: AC status ✅/⬜/❌ |
| `<DOCS>/docs.md` | `write-docs` | Read |
| `<DOCS>/.lifecycle.log` | `dev-lifecycle` | Read only. **Never append** — unknown phase names break its detection |
| `agent_docs/.reviews/*.md` | `branch-review` | Read: avoid repeating its findings in `/fe-gate` |
| `<DOCS>/test-scenarios.md` | **dev-frontend** | Written only when the user asks to save scenarios |
| `<DOCS>/fe-gate.md` | **dev-frontend** | Latest FE gate report |
| `<DOCS>/.fe-checks.log` | **dev-frontend** | Own append-only log |

## `.fe-checks.log` format

Same shape as the lifecycle log so it's familiar, but a separate file:

```
2026-09-29T10:12:03Z  check=fe-gate  status=go|go-with-notes|no-go  code=<CODE_SHA>  note=<short>
2026-09-29T10:30:40Z  check=jira-sync  status=pass  note=testplan,fe-gate
```

`CODE_SHA` = last commit touching anything outside `agent_docs/` :

```bash
CODE_SHA=$(git log -1 --format=%H -- . ':(exclude)agent_docs' | cut -c1-10)
```

A gate result is **stale** when its `code=` no longer matches the current `CODE_SHA`.

## Where dev-frontend fits in the lifecycle

```
/dev-frontend:refine-ticket   ← before planning (PO-facing)
/dev-frontend:start-branch    ← before /<lifecycle>:dev-lifecycle phase 0
/<lifecycle>:dev-lifecycle   ← plan → implement → QA → review → security
/dev-frontend:fe-gate         ← after review (phase 4), before testplan (phase 6)
/<lifecycle>:dev-lifecycle   ← testplan → docs → MR
/dev-frontend:test-scenarios  ← any time after implement; complements testplan
/dev-frontend:jira-sync       ← whenever artefacts should be visible in Jira
```
