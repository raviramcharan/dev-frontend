# Changelog

## 1.2.0 — 2026-10-02
- `/sprint-risks`: page always in your personal space under "FE Overzicht – [Project]" (created if missing); new config key `confluence.personalSpaceKey` replaces `confluence.spaceKey`.
- `/sprint-risks`: shorter page — no `#` column, max 6 short risks, no refinement questions; 🛠 marks tickets with a developer note.
- `/sprint-risks`: refinement questions move into the `sprint-risk` developer note (max 2); notes are asked before publishing.
- `/growth-log`: one heading per run, 4-column signal table (Ticket · Signal · Action · Effect); Type field dropped.

## 1.1.0 — 2026-10-02
- Developer notes are compact: tag, title and content only — no date, sources, status, separators or visibility footer.
- `/refine-ticket --apply` appends a "processed" line instead of changing a status header.
- `/sprint-risks`: compact Confluence page (verdict, top risks, refinement questions, housekeeping) and compact `sprint-risk` note; no probability/impact shown.
- `/sprint-risks`: new estimate check — story points on the main task, subtasks present, hours on subtasks. Optional config key `jira.storyPointsField`.

## 1.0.0 — 2026-09-29
- First release.
- Commands: user-story, refine-ticket, start-branch, test-scenarios, fe-gate, jira-sync, sprint-risks, growth-log.
- Output language configurable (`nl`, `en`, `auto`).
- Optional integration with a lifecycle plugin via `lifecyclePlugin`: detected and asked on first use (or by the install script); never writes to its `.lifecycle.log`.
