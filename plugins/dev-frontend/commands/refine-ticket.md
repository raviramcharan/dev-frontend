---
description: Refine a Jira ticket before planning — Definition of Ready score, open questions per role, and the enriched ticket in the ticket template, posted as a developer note (never into the description unless --apply).
argument-hint: "<TICKET-KEY> [--lang nl|en] [--apply]"
---

# /refine-ticket

Arguments: `$ARGUMENTS`

Difference with `/dev-frontend:user-story`: user-story produces paste-ready text and never writes. refine-ticket adds a **readiness check and questions for the PO**, and records the result in Jira as a developer note. Run it before `/<lifecycle>:jira-plan` — jira-plan's grilling clarifies things for *you*; refine-ticket surfaces what the *PO* still has to answer.

Use **fe-standards**: `references/jira-conventions.md`, `references/dor-dod.md`, `references/ticket-templates.md`, `references/output-language.md`.

## Steps

1. Config, output language, `cloudId`. No key → ask.
2. Load the ticket: `<DOCS>/issue.md` if present, else `getJiraIssue` with `fields: ["*all"]` (includes comments, issue links, attachments, story points, sprint). Subtask → also fetch the parent.
   Read an existing `[dev-note:refinement]` note if there is one.
3. `--apply` → skip to step 8.
4. **Template:** choose via the decision rules in `ticket-templates.md`; state the choice and reason in one sentence.
5. **Enrich:**
   - Rewrite into the template, keeping all existing information.
   - Add only what is derivable from ticket, comments, linked issues or attachments — cite each addition's source.
   - What isn't derivable becomes an open question, never an assumption. Proposed AC are phrased as questions ("Proposed AC: … — correct?").
   - Add FE states and edge cases fitting the platform (empty, loading, error, mobile, long text, out of stock…) under the template's notes/AC where they belong.
   - Main task → include the suggested FE/BE subtasks section.
6. **Definition of Ready:** score R1–R9 → Ready / Partly ready / Not refined.
7. **Preview in chat**, in this order:
   1. DoR table (criterion, status, source) + verdict
   2. **Open questions**, grouped per role (PO / BE / Design / Client)
   3. The enriched ticket
   4. Label proposal (`frontendLabel`) if the ticket contains FE work and lacks the label

   Then ask, separately:
   - "Post this as a developer note (visible to <role/group>)?" → post/update `[dev-note:refinement]`.
   - If proposed: "Add label `<frontend>`?"
8. **`--apply`** (on request, after agreeing with the PO): take the latest refinement note, incorporate answered questions from the comments, show the full new description plus what changes compared with the current one. After approval: `editJiraIssue` → `description`, then append the `processed` line (`output-language.md`) to the note.

## Never

- Change the description without `--apply` and explicit approval.
- Change status, assignee, sprint or story points.
- Create subtasks in Jira.

## Close

Partly ready / Not refined → one sentence on what blocks the ticket, and suggest sending the questions before starting. Ready → next step: `/dev-frontend:start-branch <KEY>`.
