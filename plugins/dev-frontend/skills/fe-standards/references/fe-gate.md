# FE gate — optional check after `/test`

Not a command of its own: `/dev-frontend:test` offers it at the end ("Also run the FE gate?") or runs it directly with `--gate`. It reuses the key, ticket, base and diff that test already loaded — don't fetch them again.

Goal: deliver right the first time. A lifecycle `branch-review` covers bugs, risks and code quality generically; this gate covers what front-end review keeps catching: accessibility, performance, translations, platform conventions and whether the tests were actually run.

Uses `dor-dod.md` (D1–D10), the platform section of `platform-standards.md`, `agent-docs.md`.

## 1 — Context

- Key, ticket (+ parent), base and diff: reuse from test.
- Lifecycle artefacts (if `lifecyclePlugin` is set): `<DOCS>/plan.md` (AC1…), `<DOCS>/testplan.md`, latest `agent_docs/.reviews/*.md` for this branch. **Don't repeat findings the branch-review already reported** — reference them in one line ("see review 2026-09-29-1030") instead.
- `git status --porcelain` (excluding `agent_docs/`) not clean → report; uncommitted changes are not part of the gate. Suggest committing first so the result can be stamped.
- `git log --oneline origin/<base>..HEAD` for the conventions check.
- `CODE_SHA` per `agent-docs.md`.

## 2 — Checks (cite file:line for every finding)

| Check | DoD | How |
|---|---|---|
| AC coverage | D1 | Per AC (plan.md numbering if available): ✅ covered (where) · ⚠️ partial · 🔍 not visible in diff (config/content → manual) |
| Standards | D2 | Platform section rules, on changed lines only |
| Accessibility | D3 | `wcag-audit` skill installed → run it on changed templates, keep critical/high. Otherwise baseline: labels, alt, focus, button vs link, ARIA misuse, contrast classes |
| Performance / CWV | D4 | New scripts/styles, sync third party, `<img>` without dimensions, eager below the fold, large inline SVG/data URIs, late-injected content causing layout shift |
| Responsive | D5 | Breakpoint classes/media queries present on layout changes; else 🔍 |
| Translatability | D6 | Customer-facing strings without `__()` / `\|trans` / `\| t` / `\|t` |
| Hygiene | D7 | `console.log`, `debugger`, `var_dump`, `dump(`, commented-out blocks, TODO/FIXME without ticket, hardcoded URLs, possible secrets |
| Test results | D8 | Results in `[dev-note:test-scenarios]` or `<DOCS>/test-scenarios.md`; `<DOCS>/testplan.md` ⬜/❌ items. Scenarios just generated and not yet executed → 🟠 "execute the scenarios", not 🔴 |
| Conventions | D9 | Branch name pattern; `bug/` branch → ticket key in commits |
| Build / lint | D10 | Find the scripts (package.json, `shopify theme check`, Tailwind build). **Don't run them** — show the command and ask |

## 3 — Report (output language)

```
## FE gate <KEY> — 🟢 GO | 🟠 GO with notes | 🔴 NO-GO
Diff: <n> files, +<a>/−<b> · Base: <branch> · Code: <CODE_SHA> · Review: <file or "none">

### 🔴 Blocking
1. [D3] path/file.phtml:42 — <problem> → <fix>

### 🟠 Remaining (name them in the MR)
### 🔍 Check manually
### Passed
D1 ✅ · D2 ✅ · …
```

Rules: 🔴 when an AC isn't covered, a critical/high WCAG finding, debug code, or a ❌ test. 🟠 for medium/low or 🔍 only. 🟢 when everything is covered.

For blocking findings show a concrete **before/after fix**. Change code only after approval (per fix or batch), then re-run the gate.

## 4 — Record (ask each)

1. Save report to `<DOCS>/fe-gate.md` (overwrite) and append to `<DOCS>/.fe-checks.log` (`check=fe-gate status=go|go-with-notes|no-go code=<CODE_SHA>`). **Never write to `.lifecycle.log`.**
2. Post as developer note `[dev-note:fe-gate]` per `jira-conventions.md` (`devNote.visibility`; existing note → show diff, update).
3. If this gate — or an earlier refinement — caught something early (a risk, dependency, or issue that would otherwise have come back from review/test): "Log this for your growth summary?" → append via `/dev-frontend:growth-log add` with prefilled fields.

Never move the ticket to review yourself.
