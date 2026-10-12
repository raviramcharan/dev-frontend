# Guide — working with dev-frontend

When to use which command, what to do with the result, and how to adapt the plugin. For installation and configuration see `README.md`.

## Contents
1. How it's built
2. The rhythm: what to run when
3. Per ticket
4. Acting on results
5. Worked example
6. Adapting the rules
7. Troubleshooting
8. Quick reference

---

## 1. How it's built

```
dev-frontend
├── skills/fe-standards/     ← the rules (one source of truth)
└── commands/
    ├── refine               PO: ticket + DoR + questions → description / note (asks)
    ├── start                branch conventions
    ├── test                 FE test matrix (+ optional FE gate, developer note)
    ├── sprint-risks         sprint oversight
    └── growth-log           quarterly evidence

optional: a lifecycle plugin (lifecyclePlugin in config)
          → dev-lifecycle, jira-plan, testplan, branch-review … writing to agent_docs/<KEY>/
```

- **Commands** hold the *how* (steps, formats, approval points); **fe-standards** holds the *what* (rules). Change a rule once, every command follows.
- **agent_docs/** is where a lifecycle plugin keeps state. dev-frontend reads it and adds its own files next to it. Without a lifecycle plugin, every command still works.
- **Developer notes** make that state visible in Jira for PO, testers and QA.

Always: preview → your "yes" → write. Status, assignee and sprint are never changed without approval; moving a ticket to review is always your call.

---

## 2. The rhythm

| Moment | Command | Time | What you do with it |
|---|---|---|---|
| 1–2 days before refinement | `sprint-risks refinement` | ~5 min | Take the agenda to refinement; send questions to the PO upfront |
| Right after sprint planning | `/sprint-overzicht` → `sprint-risks start` | ~10 min | Share top risks + stand-up text |
| Per ticket | see §3 | — | — |
| Mid-sprint | `sprint-risks check` | ~5 min | Raise new blockers in stand-up |
| End of quarter | `growth-log summary` | ~10 min | Input for your growth conversation |

The sprint rhythm *is* the "fixed overview moment per sprint per project" from your SMART goal. `sprint-risks` offers to log each run automatically.

---

## 3. Per ticket

| Step | Command | Your part |
|---|---|---|
| Write up the ticket + check readiness | `refine` | Choose: description, developer note or copy yourself; send open questions; later `--apply` after PO answers |
| Start | `start` | Pick base (`develop` or sprint branch), confirm branch name |
| Plan → implement → QA → review | `<lifecycle>:dev-lifecycle` (or your own flow) | One phase per run |
| Test matrix (+ FE gate) | `test` | Review, test on DDEV/test; pick: post as developer note, save, and/or run the FE gate — fix blockers until 🟢/🟠 |
| Testplan → docs → MR | `<lifecycle>:dev-lifecycle` (or your own flow) | — |

**Skip refine?** Fine for small bugs or Compact tickets with testable AC. `start` will tell you if readiness looks weak.

**test vs a lifecycle testplan:** testplan gives AC status (✅/⬜/❌) and one scenario — good for "is it built?". test gives the full matrix a tester executes — good for "does it work in every situation?". They complement each other; test reads testplan when present.

**Committed after the FE gate?** The gate is stamped with `CODE_SHA`. Re-run `test --gate` — that last small fix is often what comes back from review.

---

## 4. Acting on results

### refine / start → DoR

| Result | Action |
|---|---|
| Ready | Start |
| Partly ready | Send questions; starting is OK, mention the risk in stand-up |
| Not refined | Don't start; back to refinement or a quick sync with the PO |

### FE gate (from test)

| Result | Action |
|---|---|
| 🟢 GO | Save or post, continue the lifecycle |
| 🟠 GO with notes | List the remaining points in the MR so the reviewer doesn't "find" them |
| 🔴 NO-GO | Apply the proposed fixes (or fix yourself), commit, re-run. Never hand over on 🔴 |

🔍 *Check manually* = not derivable from the diff (admin config, content, browser behaviour). Walk through them yourself — they're the usual cause of "doesn't work on test".

### sprint-risks

| Verdict | Action |
|---|---|
| 🟢 | Share stand-up text |
| 🟠 (e.g. readiness < 70%) | Agree with the PO which tickets get refined first or leave the sprint |
| 🔴 | Raise immediately — usually a hard blocker (BE, design, client) without an owner |

---

## 5. Worked example

*Fictional ticket SHOP-412 "Product listing — filter on material" (Hyvä), sprint 42.*

1. `refine SHOP-412` → *Partly ready*: no design (R3), unclear which attribute BE delivers (R5). Questions: [Design] "Is there a Figma frame for the filter chips on mobile?" [BE] "Is `material` a filterable attribute in the GraphQL response?" → posted as developer note.
2. Answers arrive. `start SHOP-412` → "Branch off which base?" → you pick `sprint/42` → `feature/SHOP-412`.
3. Plan → implement → QA → review (e.g. `<lifecycle>:dev-lifecycle`, review against `sprint/42`).
4. `test` → Maintenance/Admin (attribute *Use in Layered Navigation*), 4 happy paths, 5 edge cases including a long material name on 360px. You pick "post as developer note" and "also run the FE gate".
5. FE gate → 🔴: the filter toggle is an `<a>` without `href` (D3), a `console.log` remains (D7). Fixed → `test --gate` → 🟢. One scenario fails on test; you fix and commit.
6. Testplan → docs → MR.
7. At sprint start, `sprint-risks start` had flagged the missing BE link for `material` → logged as an early signal, later one of your three examples in `growth-log summary`.

---

## 6. Adapting the rules

All rules live in `skills/fe-standards/`:

| To change… | Edit |
|---|---|
| Branch patterns, commit convention, note format, visibility | `references/jira-conventions.md` |
| Ticket templates, decision rules | `references/ticket-templates.md` |
| Labels per language, add a language | `references/output-language.md` |
| DoR/DoD criteria or thresholds | `references/dor-dod.md` |
| Platform rules (new Hyvä convention, Sonar rule) | `references/platform-standards.md` |
| Per-project settings | `<repo>/.claude/dev-frontend.json` |

Tip: when review or test catches something the gate could have caught, add it to `platform-standards.md`. The gate gets sharper every sprint. Useful for others too? Propose it upstream to your lifecycle plugin.

After editing: bump `version` in `.claude-plugin/plugin.json` and the marketplace entry, add a CHANGELOG line, push, then `scripts/dev-frontend.sh update` (see the repository README).

---

## 7. Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| "Visibility could not be set" | Role `Developers` doesn't exist in this project | Look up the role (Project settings → People), set it in the project config |
| Test scenarios visible to the whole team | No private group | Ask a Jira admin for a group with only you → `devNote.privateVisibility` |
| Output in the wrong language | `auto` picked up the ticket language | Set `outputLanguage` explicitly or use `--lang` |
| "No active sprint" | Sprint not started | Use `sprint-risks refinement` or pass the sprint name |
| Tickets missing from sprint analysis | `frontend` label missing | Listed under "without label"; add after approval |
| `start` stops immediately | Dirty working tree | Commit or stash first |
| Sprint branch not in the list | Doesn't match `sprintBranchPatterns` | Add the pattern in project config |
| Key resolved as `UPDATE-2` | Branch without ticket key | Pass the key as argument |
| Lifecycle diff against the wrong base | Lifecycle skills often auto-detect `origin/HEAD` | Pass the base explicitly, e.g. `/<lifecycle>:branch-review sprint/42` |
| FE gate stale (`code=` ≠ current commit) | Commits after the gate | Re-run `test --gate` |
| Duplicate notes instead of updates | First-line tag edited by hand | Keep `[dev-note:<type>]` exactly |
| `/user-story` still shows up | Local command or older plugin version | Remove it from `~/.claude/commands/`; use `refine` |

---

## 8. Quick reference

```
/dev-frontend:refine <KEY> [--apply]   ticket + DoR + questions → asks: description / note / none
/dev-frontend:start <KEY>              readiness → branch (asks base)
/dev-frontend:test [KEY] [--gate]      test matrix → asks: note / save / FE gate
/dev-frontend:sprint-risks [refinement|start|check]
/dev-frontend:growth-log summary [Q4-2026]

Every command: --lang nl|en
```
