# Jira and git conventions

## Developer notes

A developer note is a Jira comment with restricted visibility. Post with `addCommentToJiraIssue`, `contentFormat: "markdown"`, `commentVisibility` from config.

### Format (labels from `output-language.md`)

```
[dev-note:<type>]
🛠 <note_type label> — <title>

<content>
```

The first line is a machine tag — keep it exact and in English regardless of output language; it's how existing notes are found and updated.
Allowed `<type>` values: `refinement`, `plan`, `testplan`, `test-scenarios`, `fe-gate`, `docs`, `sprint-risk`.

Keep notes compact: no dates, links, sources, status line, `---` separators or visibility footer. Say which role/group will see the note in the chat preview only.

### Visibility

| Note type | Config key | Default |
|---|---|---|
| all types | `devNote.visibility` | `{ "type": "role", "value": "Developers" }` |
| `test-scenarios` | `devNote.privateVisibility`, falls back to `devNote.visibility` | `null` |

Jira restricts comments to a **role** or **group**, never to one person. "Only me" needs a Jira group containing only the user (created by a Jira admin), set as `privateVisibility`. Until then, say in the preview which role will see the note.

If visibility cannot be set (role/group doesn't exist, permission error): **post nothing**, report the error, ask which role or group to use. Never fall back to a public comment.

### Idempotent updates

1. `getJiraIssue` with `fields: ["comment"]`.
2. Find the comment whose body starts with `[dev-note:<type>]`.
3. Found → show a diff old vs new; after approval update it via `commentId`. **Preserve human-entered values** (test results, PO answers, ticked boxes).
4. Not found → create a new one.
5. Jira comments are capped around 32,000 characters. Content longer than ~25,000 → post a summary and link to the MR / agent_docs path instead of truncating silently.

### From note to description

Only on explicit request (e.g. `/dev-frontend:refine-ticket PROJ-1 --apply`): show the full new description as a preview, then `editJiraIssue` on `description` after approval and set the note status to *processed*.

## Labels

FE tickets carry `frontendLabel` (default `frontend`) so `/sprint-overzicht` and `/dev-frontend:sprint-risks` find them. Adding a label is a ticket edit: propose it, apply only after approval.

## Branches

| Ticket type | Pattern | Example |
|---|---|---|
| Story, Task, Sub-task (feature) | `feature/<PROJ>-<TICKETNR>` | `feature/SHOP-412` |
| Bug | `bug/bugfix-<short-description>` | `bug/bugfix-minicart-qty-reset` |
| Support (issuetype "Support" or project `SUPPORT`) | `support/SUPPORT-<TICKETNR>` | `support/SUPPORT-88` |

`<short-description>`: kebab-case, lowercase, English, 2–5 words, derived from the summary. Propose it; the user confirms or edits. Type unclear (e.g. a bug filed as a Task) → ask.

### Base branch — always ask

1. `git fetch --prune`
2. Show candidates: branches from `branches.baseCandidates` (default `develop`) that exist on the remote, plus remote branches matching `branches.sprintBranchPatterns`, sorted by last commit date, each with that date.
3. Ask "Branch off which base?" — **never choose, not even with a single candidate.** You may hint (e.g. "ticket is in Sprint 42; `sprint/42` exists"), never decide.
4. Working tree must be clean (`git status --porcelain`); otherwise stop and report.
5. Create: `git switch -c <branch> origin/<base>`.

Lifecycle skills (`jira-plan`, `dev-lifecycle`, `testplan`, `branch-review`) typically auto-detect the base via `origin/HEAD`. When calling or following them, pass the chosen base explicitly where they accept it (e.g. `/<lifecycle>:branch-review <base>`), so they diff against the branch the user actually chose.

### Commits

`bug/` branches carry no ticket key. Advise `<PROJ>-<NR>: <summary>` in every commit message so the work stays traceable from Jira — and so lifecycle skills can resolve the key from `agent_docs/` rather than the branch name.
