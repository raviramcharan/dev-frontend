---
name: fe-standards
description: Shared rules for every dev-frontend command — config loading, output language, Jira developer notes, branch naming, Definition of Ready/Done, ticket templates, platform standards (Hyvä/Magento 2, Shopware/Twig, Shopify/Liquid, Drupal) and how to read agent_docs/ artefacts from an optional lifecycle plugin. ALWAYS use this skill when any /dev-frontend:* command runs, and whenever the user asks to write or refine a Jira ticket, start a branch, post a developer note, or check front-end code against these standards.
---

# fe-standards

Single source of truth for the `dev-frontend` commands. Commands point here instead of repeating rules. Read only the reference file a step needs.

## Core principles (every command)

1. **Supportive and traceable, not autonomous.** Show a preview in chat first. Write to Jira, Confluence, git or the filesystem only after an explicit "yes". One approval covers one action.
2. **Cite the source** of every conclusion (ticket field, comment, file:line, linked issue, agent_docs file). Write "not derivable from the ticket" instead of guessing.
3. **Never overwrite a ticket description directly.** Tool output goes into a *developer note* first (`references/jira-conventions.md`).
4. **Complement a lifecycle plugin, never duplicate it.** If `lifecyclePlugin` is set in config, that plugin owns the dev lifecycle (plan → implement → review → MR) and its `agent_docs/` artefacts. This plugin reads them and never writes to files it owns (`references/agent-docs.md`).

## `<lifecycle>` placeholder

Wherever these instructions write `/<lifecycle>:<skill>` (e.g. `/<lifecycle>:dev-lifecycle`), substitute the config value `lifecyclePlugin` — the namespace of an installed plugin that provides skills such as `dev-lifecycle`, `jira-plan`, `testplan`, `branch-review`, `write-docs`.

### Resolving `lifecyclePlugin` (run once, before the first step that needs it)

The key has three states — treat them differently:

| State in merged config | Meaning | Behaviour |
|---|---|---|
| **key absent** | never decided | Detect and ask (below) |
| `null` | user chose standalone | Never ask again; skip lifecycle steps |
| `"<namespace>"` | user chose a plugin | Use it. If its skills aren't available in this session, say so in one line and continue standalone for this run — don't change the config |

**Detect and ask** (only when the key is absent):

1. Look at the skills/commands available in this session for any namespace that provides `dev-lifecycle`, or at least two of `jira-plan`, `testplan`, `branch-review`, `write-docs`. Also note whether the repo has an `agent_docs/` directory with a `.lifecycle.log`.
2. **One candidate found** → ask a single question:
   > "I see `/<ns>:dev-lifecycle`. Use `<ns>` as your lifecycle plugin?"
   > **Yes, everywhere** (writes `~/.claude/dev-frontend.json`) · **Only this project** (writes `<repo>/.claude/dev-frontend.json`) · **No, run standalone** (writes `null` to your personal config)
3. **Several candidates** → same question, listing each namespace as an option, plus "No, run standalone".
4. **None found** → don't ask and don't write anything; run standalone this time. (The check repeats next run, so installing a lifecycle plugin later gets picked up.) If `agent_docs/.../.lifecycle.log` exists but no plugin was found, mention in one line that a lifecycle plugin seems to be used in this repo but isn't installed.
5. Write the chosen value only after the answer, merging into the existing config file (never overwrite other keys). Then continue the command that triggered the question.

Ask this at most once per session, and never in the middle of a preview/approval step.

## Config

Load in this order, later wins:
1. `~/.claude/dev-frontend.json` (personal)
2. `<repo-root>/.claude/dev-frontend.json` (project)

Example: `config/dev-frontend.example.json` in this plugin. If a value a step needs is missing, ask once and offer to write it to the project file (with approval).

Atlassian `cloudId`: call `getAccessibleAtlassianResources` (no arguments), pick the resource whose `scopes` include `read:jira-work`. More than one qualifies → ask which instance. Never hardcode.

## Output language

`outputLanguage` in config: `nl` (default), `en`, or `auto` (same language as the Jira ticket, detected from summary/description).

- A per-run override always wins: `--lang en` / `--lang nl` on any command.
- Instructions in this plugin are in English; **everything written for humans** (ticket text, notes, scenarios, reports, Confluence pages, chat summaries) follows the output language.
- Fixed labels per language: `references/output-language.md`. Use exactly those labels so outputs stay consistent across tickets.

## Reference files

| File | Read when |
|---|---|
| `references/jira-conventions.md` | Any Jira write, developer note, label, or git branch action |
| `references/agent-docs.md` | Any command that reads lifecycle artefacts or resolves `<DOCS>` |
| `references/ticket-templates.md` | `/user-story`, `/refine-ticket` |
| `references/dor-dod.md` | Readiness checks (`/refine-ticket`, `/start-branch`, `/sprint-risks`) and `/fe-gate` |
| `references/platform-standards.md` | `/fe-gate`, `/test-scenarios`; read only the detected platform's section |
| `references/output-language.md` | Before writing any human-facing output |

## Platform detection

Use `platform` from config unless it is `auto`. Otherwise check in this order, stop at the first match:

- **Hyvä (Magento 2)**: `hyva.config.json`, or `vendor/hyva-themes/`, or Tailwind config alongside `app/design/frontend/*/hyva-*`
- **Magento 2 (Luma/other)**: `bin/magento` at the root, or `app/code/<Vendor>/<Module>/`, without Hyvä markers
- **Shopware**: `composer.json` requires `shopware/core` or `shopware/platform`, or `custom/plugins/` exists
- **Shopify**: `shopify.app.toml` / `shopify.theme.toml`, or `sections/`, `templates/`, `snippets/`, `layout/theme.liquid`
- **Drupal**: `composer.json` requires `drupal/core`, or `web/modules/custom/` / `web/themes/custom/`

Not confident → ask. Without a repo (e.g. `/user-story`), default to Hyvä unless the ticket says otherwise.

## Jira key from a branch

Extract the first `<LETTERS>-<DIGITS>` pair, uppercase it:

```bash
git rev-parse --abbrev-ref HEAD | grep -oiE '[a-z]+-[0-9]+' | head -1 | tr '[:lower:]' '[:upper:]'
```

Sanity-check it: branches like `feature/magento-update-2-4-7-p10` yield nonsense (`UPDATE-2`), and `bug/bugfix-…` branches carry no key at all. If it looks wrong or the fetch returns nothing, ask for the key.

## Subtasks

If the issue has a `parent` or `issuetype.subtask == true`, also fetch the parent. Parent = feature context and overall acceptance criteria; subtask = the actual scope of this work. Conflicting signals → treat as a subtask; the parent relation decides.
