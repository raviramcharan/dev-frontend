---
description: Evidence for the helicopter-view growth goal — records overview moments and early-signalled risks (mostly offered automatically by sprint-risks and fe-gate) and produces a quarterly summary for the growth conversation.
argument-hint: "[summary [Q<n>-<year>] | add] [--lang nl|en]"
---

# /growth-log

Arguments: `$ARGUMENTS`

Makes the SMART goal *helicopter view FE* measurable: one fixed overview moment per sprint per active project, and how often an early signal led to action.

You rarely call `add` yourself — `/dev-frontend:sprint-risks` and `/dev-frontend:fe-gate` offer it at the right moment with fields prefilled. The command you run yourself is `summary`, once a quarter.

## Storage

From `growthLog` in `~/.claude/dev-frontend.json` (personal config only — never the project file):

| `location` | Where | Note |
|---|---|---|
| `confluence` *(default)* | Personal space `confluenceSpaceKey` → parent `parentTitle` → child per quarter (`growth_page` label) | Shareable with your coach via one page. Check your personal space permissions — they differ per organisation |
| `local` | `localPath/<year>-Q<n>.md` | Fully private, offline; export to share |

First use without config → ask the location and save it (with approval). Quarter page/file missing → create after approval.

## `add` (default when called by another command)

Fields (prefill what's known, ask only what's missing):
Date · Project · Sprint · Ticket(s) · **Type** (Overview moment / Risk / Dependency / Scope issue / Quality) · **Signalled** (1–2 sentences) · **Moment** (refinement / sprint start / during development / before delivery) · **Action** (what you did, with whom) · **Effect** (prevented / resolved earlier / scope changed / still open).

Show the row as a preview → append after approval to the quarter table:

```
| Date | Project | Sprint | Ticket | Type | Signalled | Moment | Action | Effect |
```

## `summary`

For the given quarter (default: current):

```
## Growth log <Q> <year> — helicopter view FE

Overview moments: <n> of <expected: sprints × active projects> (<x>%)
Signalled early: <n> risks/dependencies, <n> led to action
By moment: refinement <n> · sprint start <n> · development <n> · delivery <n>
  → the more signals land early, the stronger the overview

### 3 strongest examples (for the growth conversation)
1. <situation → what you saw → what you did → effect>

### Patterns
### Focus for next quarter
```

Base examples and patterns **only** on logged rows. Ask for the expected number of overview moments if it isn't derivable. Offer to place the summary at the top of the quarter page.
