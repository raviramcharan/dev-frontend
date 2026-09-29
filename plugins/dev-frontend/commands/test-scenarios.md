---
description: Generate a structured test scenario matrix (Maintenance/Admin, Happy Path, Edge Cases) from the current branch's changes, cross-referenced with the Jira ticket. Output only — nothing is posted anywhere unless asked afterwards.
argument-hint: "[<ISSUE-KEY>] [--lang nl|en|auto] [--base <branch>]"
---

# /test-scenarios

Arguments: `$ARGUMENTS`

Analyse the changes on this branch and generate a structured test scenario matrix — grouped into fixed categories that go beyond the happy path — for a developer or PO to execute manually. Print the result in chat. Do **not** post it anywhere (no Jira comment, no file write) unless the user explicitly asks afterwards.

Use the **fe-standards** skill: config, output language, Jira-key extraction, subtask handling, platform detection (SKILL.md); admin surfaces per platform (`references/platform-standards.md`); fixed labels (`references/output-language.md`); lifecycle artefacts (`references/agent-docs.md`).

## Step 1: Determine the Jira issue key

Use the argument if given (e.g. `PROJ-1234`). Otherwise derive it from the branch name per fe-standards. Branch naming varies across projects — `feature/PROJ-8309-sticky-atc`, `fix/PROJ-382-json-bug`, `run/SUP-118-product-registration` are all in use. Sanity-check the result: `feature/magento-update-2-4-7-p10` produces nonsense like `UPDATE-2`, and `bug/bugfix-…` branches have no key. If the key looks wrong, or the fetch in Step 3 returns no issue, stop and ask instead of guessing.

## Step 2: Discover the Atlassian instance

Per fe-standards: `getAccessibleAtlassianResources`, resource with `read:jira-work` scope; more than one → ask. Never hardcode a cloud ID.

## Step 3: Fetch the issue (and parent, if it's a subtask)

If `<DOCS>/issue.md` exists, use it as the authoritative ticket content. Otherwise `getJiraIssue` with `fields`: `summary`, `description`, `issuetype`, `parent`, `status`.

Subtask (has a `parent`) → also fetch the parent. Subtasks often carry thin or no acceptance criteria — draw on both:
- the **parent's** description/acceptance criteria for overall feature context;
- the **subtask's** own description for what this branch implements.

**Lifecycle artefacts (if present):** read `<DOCS>/plan.md` (numbered AC1…) and `<DOCS>/testplan.md` (AC status). Use them to check you haven't missed a criterion, and to align scenario names with AC numbers where natural. They don't replace the diff as the grounding.

## Step 4: Analyse the branch diff

Base branch: `--base` if given; otherwise detect the default remote branch:

```bash
git symbolic-ref -q refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'
```

Nothing (common on fresh clones/CI) → fall back:

```bash
git branch -r | grep -E 'origin/(main|master|develop|sprint/[^ ]+)' | head -1 | sed 's|.*origin/||'
```

Neither usable → ask which base to diff against. The ticket may have been branched from a sprint branch rather than the default — if a `sprint/*` branch exists and is closer (fewer commits via `git merge-base`), mention it and confirm.

```bash
git diff "$(git merge-base HEAD "origin/$BASE")"..HEAD -- ':!*.lock' ':!generated/' ':!pub/static/' ':!agent_docs/'
```

Empty diff → do **not** silently fall back to a single commit (that yields a misleadingly thin set). Tell the user there are no changes against `$BASE` and ask how to proceed (another base, or `HEAD~1..HEAD` if that is genuinely wanted).

Identify: changed features/fixes/behaviours; touched templates, controllers, blocks, view models, JS/CSS; configuration or schema changes; edge cases implied by the code (empty states, permission checks, validation, error paths, loading states).

## Step 5: Detect the platform

Per fe-standards. Not confident → ask before continuing: the Maintenance/Admin category depends on knowing where *admin-clickable* settings live (table in `platform-standards.md`) — not on code-level config, which that category deliberately excludes.

## Step 6: Generate the test scenarios

Output language: `--lang`, else config `outputLanguage`. With `auto`, use the ticket's language (detect from summary/description — don't assume Dutch). Take every label from `output-language.md` → *Test scenarios*.

Use this structure exactly (shown with `nl` labels):

```
# 🧪 Testscenario's: [ISSUE-KEY] — [ticket titel]

**Platform:** [🐝 Hyvä/Magento | 🟠 Magento (Luma) | 🔵 Shopware | 🟢 Shopify | 💧 Drupal]
**Branch:** `[huidige branch]`

## 🎯 Scope
**In scope:** [componenten/bestanden/flows die daadwerkelijk zijn aangeraakt door deze branch]
**Out of scope:** [aanpalende dingen die bewust niet zijn meegenomen, met reden]

## ⚙️ Maintenance/Admin

**🔹 Scenario: [naam]** *(instellingen die iemand in het admin-paneel moet aanpassen of controleren voordat/tijdens het testen — geen technische/developer-config)*
Stappen:
1. [Stap]
➡️ Verwacht resultaat: [...]

---

## ✅ Happy Path

**🔹 Scenario: [naam]**
Stappen:
1. [Stap]
2. [Stap]
➡️ Verwacht resultaat: [Wat de tester zou moeten zien/ervaren]

---

**🔹 Scenario: [naam]** *(herhaal per happy-path scenario dat de diff rechtvaardigt)*
Stappen:
1. [Stap]
➡️ Verwacht resultaat: [...]

---

## 🧩 Edge Cases

**🔹 Scenario: [naam]**
Stappen:
1. [Stap]
➡️ Verwacht resultaat: [...]

---

## ⚠️ Aannames / bekende beperkingen
[Alles wat hier expliciet niet getest kon worden, bijv. geen staging betaalomgeving beschikbaar]
```

Section emoji (use exactly these, every time):

| Section | Emoji |
|---|---|
| Title | 🧪 |
| Scope | 🎯 |
| Maintenance/Admin (header) | ⚙️ |
| Happy Path (header) | ✅ |
| Edge Cases (header) | 🧩 |
| Individual scenario name | 🔹 |
| Expected result | ➡️ |
| Assumptions / limitations | ⚠️ |
| Platform: Hyvä/Magento | 🐝 |
| Platform: Magento (Luma) | 🟠 |
| Platform: Shopware | 🔵 |
| Platform: Shopify | 🟢 |
| Platform: Drupal | 💧 |

## Rules

- **Three categories only, in this order: Maintenance/Admin, Happy Path, Edge Cases.** No sub-splitting into error handling, responsive, a11y, state or regression sections — fold anything relevant into Happy Path or Edge Cases (e.g. a validation error belongs under Edge Cases).
- **Omit a whole category** only when genuinely not applicable — e.g. no admin surface at all → skip Maintenance/Admin. Never print an empty heading or a filler scenario.
- **Maintenance/Admin is strictly admin-panel-facing, non-technical setup** — what a PO, merchandiser or content editor clicks through in the admin UI before or during testing: Stores→Configuration values (Magento/Hyvä), CMS blocks/widgets, plugin settings screens (Shopware), theme editor placement or metafield values (Shopify), module settings forms (Drupal), required test accounts/roles/test data. **Not** developer-only or code-level setup — no feature flags requiring a deploy, no `.env`/config-file changes, no composer/module installation, no cache flush/reindex commands, nothing that isn't clickable without dev access. If the only prerequisite is technical, leave it out; omit the category if nothing admin-clickable remains.
- Each scenario is a self-contained block: `🔹 Scenario: [naam]`, a numbered steps list, and one `➡️` expected-result line. No tables.
- **A `---` separator after every scenario's expected-result line**, including the last one in each category.
- Multiple scenarios per category are expected — one is a floor, not a ceiling. As many as the diff genuinely justifies.
- **Emoji only in these exact spots**: section headers, the platform label, `🔹` before each scenario name, `➡️` before each expected result. Nowhere else — not on steps, not in step text, not as extra decoration.
- Be concrete — name the actual page, button, field, template or URL. No generic scenarios like "test the form."
- Steps are numbered and imperative ("Vul qty in als 0", not "qty zou 0 moeten kunnen zijn").
- Ground every scenario in the actual diff — no scenarios for untouched code. Use the ticket's acceptance criteria (and the parent's, if applicable) to sanity-check you haven't missed a scenario the ticket implies but the diff doesn't make obvious.
- Print in chat only.

## After the output (one line, nothing more)

Offer the follow-ups without doing them: save to `<DOCS>/test-scenarios.md`, and/or post as a private developer note via `/dev-frontend:jira-sync <KEY> test-scenarios`. Only act if the user explicitly asks.
