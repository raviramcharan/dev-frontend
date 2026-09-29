# Definition of Ready & Definition of Done (front-end)

## Definition of Ready — 9 criteria

Rate each ✅ present · ⚠️ partial · ❌ missing, always with the source.

| # | Criterion | Where |
|---|---|---|
| R1 | **Goal / why** is clear | Description |
| R2 | **Acceptance criteria** are testable (observable, no "works well") | Description / AC field |
| R3 | **Design** available for UI changes (Figma link, screenshot, or explicit "no design needed") | Description, attachments, links |
| R4 | **Scope boundary** — what is explicitly out | Description |
| R5 | **Dependencies** named (BE, API, content, third party, other tickets) | Issue links, description |
| R6 | **Context**: store view, language, device, page or template | Description |
| R7 | **Content & translations** arranged | Description |
| R8 | **Estimate** present and ≤ 8 SP (larger → consider splitting) | Story points |
| R9 | **No unanswered questions** in comments | Comments |

Score:
- **Ready**: ≥ 8 ✅ and no ❌ on R2, R3, R5.
- **Partly ready**: 5–7 ✅, or a ❌ on R2/R3/R5 with a clear owner.
- **Not refined**: < 5 ✅, or R1 or R2 entirely missing.

For every ⚠️/❌, write **one concrete question** tagged with the role that can answer it: PO, BE, Design, Client.

## Definition of Done — front-end

| # | Criterion |
|---|---|
| D1 | Every acceptance criterion demonstrably covered (diff and/or test) |
| D2 | Meets platform standards (`platform-standards.md`) |
| D3 | WCAG 2.2 AA: no critical/high findings on changed templates |
| D4 | No Core Web Vitals regression: no new render-blocking assets, no layout shift, images with dimensions and lazy loading |
| D5 | Responsive checked (mobile / tablet / desktop) |
| D6 | All customer-facing strings translatable |
| D7 | No debug code, `console.log`, commented-out blocks, or TODOs without a ticket |
| D8 | Test scenarios executed and results recorded |
| D9 | Branch name and commits follow the convention |
| D10 | Build/lint passes (Tailwind build, theme check, linters) |
