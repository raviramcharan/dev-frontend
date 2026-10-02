---
description: Make risks and dependencies of front-end tickets in a sprint visible — before refinement, at sprint start, or as a mid-sprint check — including tickets that aren't refined yet. Publishes in your personal Confluence space under "FE Overzicht – [Project]".
argument-hint: "[refinement|start|check] [PROJECT-KEY] [sprint name] [--lang nl|en]"
---

# /sprint-risks

Arguments: `$ARGUMENTS`

Use **fe-standards**: `references/dor-dod.md`, `references/jira-conventions.md`, `references/output-language.md`. Pages live in your personal space: "FE Overzicht – [Project]" → the risk page.

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
| Size | > 8 SP, no estimate (see Estimate), or carried over from a previous sprint |
| Estimate | Main task without story points; no subtasks created; subtasks without an hour estimate (name which) |
| Capacity | No assignee, or one person holding most FE SP |
| Quality | Several bugs on the same area, or a ticket reopened before |

Assess probability and impact (Low / Medium / High) internally, only to rank risks most serious first. Don't show them on the page or in notes.

### Estimate check — every ticket, also Not refined

Fetch `subtasks`, the story points field, and per subtask `timetracking` (original estimate).
- Story points field id differs per Jira instance: use `jira.storyPointsField` from config. Missing → find it once via field metadata (name "Story Points" / "Story point estimate") and suggest adding it to config.
- Per ticket: SP ✅/❌ · subtasks <n> · without hours <n>. Missing items count as a refinement question (PO for SP, Dev for subtasks/hours).

Optional (ask first): with a local repo, check which ticket branches exist and whether they touch the same files (`git diff --stat` per branch) to make overlap concrete. If `agent_docs/<KEY>/plan.md` files exist, use their milestone file lists for the same purpose.

## Output

### Chat preview

```
## FE sprint risks — <Project> · <Sprint> · mode: <mode> · <date>
Readiness: <x>% ready (<n> ready · <n> partly · <n> not refined)
Sprint verdict: 🟢 / 🟠 / 🔴 — <one sentence>

### Top risks (most serious first)
| # | Risk | Tickets | Action (owner) |

### Dependencies
| Ticket | Depends on | Type | Status of dependency | Consequence |
(+ a mermaid diagram in chat only)

### Overlap / order
### Estimates
| Ticket | SP | Subtasks | Without hours |
### Not refined — questions
### FE tickets without label
### Stand-up text (copyable, max 5 lines)
```

`check` → start with a **delta** against the previous risk page (new / resolved / unchanged).

### Publish (after approval)

1. Location — always your personal space → `confluence.overviewParentTitle` (default "FE Overzicht – [Project]") → the page (title `fe_risks_page`). No sprint-level page in between.
   - Space key: `confluence.personalSpaceKey` → else `growthLog.confluenceSpaceKey` → else the current user's personal space (`~<accountId>` via `atlassianUserInfo`); in that last case suggest saving it to config.
   - Project page missing → create it (empty) as part of the same approved publish; say so in the preview.
2. `refinement` → `fe_refinement_page` title.
3. `check` → update the same risk page with an "Update <date>" section; no new page.
4. Tables only on Confluence (no native Mermaid).

### Page content — compact

The page is shorter than the chat preview:

```
# <fe_risks_page>
**Verdict:** 🟢/🟠/🔴 <max ~20 words> · **Readiness:** <n> ready · <n> partly · <n> not refined (of <n>)

## Top risks
| Risk | Tickets | Action (owner) |

🛠 = <dev_note_legend>

## Housekeeping
- <missing labels, missing links, duplicates, board state, excluded tickets — one line each>
- <dev_notes_on>: <KEY>, <KEY>, …
```

- No `#` column. Max 6 risks, most serious first.
- Risk: max ~15 words, one idea, no sub-lists. Action: max ~12 words + owner. A required work order goes into the Action ("252 → 329 → 331").
- Tickets with a `[dev-note:sprint-risk]` get a 🛠 after the key (`JDP-42 🛠`). The housekeeping line lists all of them, also tickets outside the top risks.
- No refinement questions on the page — they go into the dev-notes (and stay in the chat preview).
- Leave out: mode, date, sources footer, probability/impact, Dependencies/Order sections, stand-up text (chat only), file lists and commit details. Write durations instead of dates ("for 5+ days").
- `check` → an "Update" section with only new and resolved bullets.

### Follow-ups — ask each separately

Ask about dev-notes **before** publishing the page, so the 🛠 markers are right on the first publish. Notes posted later → update markers and the housekeeping line on the page (after approval).

- Post `[dev-note:sprint-risk]` on high-risk tickets and on tickets with refinement questions? List them first. Compact content, nothing else:

  ```
  [dev-note:sprint-risk]
  🛠 <note_type: sprint-risk> — <short risk title>

  Risk: <1–3 concrete sentences; mention "not refined" or missing estimates here if relevant>

  Action: <one sentence>

  <questions>: <question> (<role>) · <question> (<role>)
  ```
  The questions line holds max 2 questions (including missing SP, subtasks or hours); leave it out when there are none. Only questions, no real risk → leave out the Risk line instead.
- Create missing `blocks` links in Jira? Show the list first.
- **Growth log:** every run is an *overview moment*; each early-signalled risk the user acts on is an *early signal*. Ask: "Log this run (+ <n> signals) for your growth summary?" → `/dev-frontend:growth-log add`.
