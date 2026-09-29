---
description: Make risks and dependencies of front-end tickets in a sprint visible — before refinement, at sprint start, or as a mid-sprint check — including tickets that aren't refined yet. Publishes under the FE Overzicht page in Confluence.
argument-hint: "[refinement|start|check] [PROJECT-KEY] [sprint name] [--lang nl|en]"
---

# /sprint-risks

Arguments: `$ARGUMENTS`

Use **fe-standards**: `references/dor-dod.md`, `references/jira-conventions.md`, `references/output-language.md`. Page structure follows `/sprint-overzicht`: parent "FE Overzicht – [Project]" → "Sprint [name] – FE Overzicht".

## When to run which mode

| Mode | Moment | Sprint (JQL) | Focus |
|---|---|---|---|
| `refinement` | 1–2 days before refinement | `sprint in futureSprints()` (next one), or the given sprint name | Readiness + question list = refinement agenda |
| `start` *(default)* | Right after sprint planning | `sprint in openSprints()` | Full risk & dependency analysis |
| `check` | Mid-sprint, or after a scope change | `sprint in openSprints()` | Delta since `start`, new blockers |

No mode → `start` if there's an active sprint, else `refinement`. Several active/future sprints → ask.

JQL: `project = <KEY> AND <sprint filter> AND labels = <frontendLabel>`. Also query the same sprint **without** the label filter and list tickets that look like FE work but lack the label, separately. Don't label them yourself.

## Tickets that aren't refined yet

They **don't block** the analysis; they become their own risk category.

1. Score every ticket on the DoR → Ready / Partly ready / Not refined.
2. Ready and Partly ready → full analysis below.
3. Not refined →
   - never invent dependencies or estimates; only what the ticket explicitly says counts;
   - risk = *scope uncertain*, impact from story points (or "unknown");
   - max 3 concrete refinement questions per ticket, tagged with a role.
4. Top of the report: **readiness** = % of FE story points (or ticket count if SP are missing) that is Ready.
   - `start`/`check` with readiness < 70% → sprint verdict 🟠, suggest raising it with the PO in stand-up.
   - `refinement` → the questions become the refinement agenda.

## Risk signals (Ready / Partly ready) — cite the source

| Category | Signal |
|---|---|
| Blocker | Linked `is blocked by` / `depends on` not Done, or not in this sprint |
| BE / API | Mentions endpoint, GraphQL, module, field, import or config without a linked BE ticket |
| Design | UI change without Figma link or attachment |
| Content / client | Waiting on copy, translations, images or client approval |
| Overlap | Several tickets touch the same page, template, component or section → order them, merge-conflict risk |
| Third party | Payment, GTM/tracking, Klaviyo, third-party extensions/apps |
| Size | > 8 SP, no estimate, or carried over from a previous sprint |
| Capacity | No assignee, or one person holding most FE SP |
| Quality | Several bugs on the same area, or a ticket reopened before |

Probability and impact: Low / Medium / High with a one-line reason.

Optional (ask first): with a local repo, check which ticket branches exist and whether they touch the same files (`git diff --stat` per branch) to make overlap concrete. If `agent_docs/<KEY>/plan.md` files exist, use their milestone file lists for the same purpose.

## Output

### Chat preview

```
## FE sprint risks — <Project> · <Sprint> · mode: <mode> · <date>
Readiness: <x>% ready (<n> ready · <n> partly · <n> not refined)
Sprint verdict: 🟢 / 🟠 / 🔴 — <one sentence>

### Top risks
| # | Risk | Tickets | Probability | Impact | Action | Owner |

### Dependencies
| Ticket | Depends on | Type | Status of dependency | Consequence |
(+ a mermaid diagram in chat only)

### Overlap / order
### Not refined — questions
### FE tickets without label
### Stand-up text (copyable, max 5 lines)
```

`check` → start with a **delta** against the previous risk page (new / resolved / unchanged).

### Publish (after approval)

1. Find or create the page (title from `output-language.md`: `fe_risks_page`) as a child of "Sprint [name] – FE Overzicht". Overview page missing → offer to run `/sprint-overzicht` first, or place it under "FE Overzicht – [Project]".
2. `refinement` → `fe_refinement_page` title.
3. `check` → update the same risk page with an "Update <date>" section; no new page.
4. Tables only on Confluence (no native Mermaid).

### Follow-ups — ask each separately

- High-risk tickets: post `[dev-note:sprint-risk]`?
- Create missing `blocks` links in Jira? Show the list first.
- **Growth log:** every run is an *overview moment*; each early-signalled risk the user acts on is an *early signal*. Ask: "Log this run (+ <n> signals) for your growth summary?" → `/dev-frontend:growth-log add`.
