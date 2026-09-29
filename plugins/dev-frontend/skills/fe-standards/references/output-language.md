# Output language — fixed labels

Use these labels verbatim for the active output language. For `auto`, pick the column matching the ticket language (fall back to `nl`).

## Test scenarios (`/test-scenarios`)

| Key | nl | en |
|---|---|---|
| title | 🧪 Testscenario's | 🧪 Test scenarios |
| scope | 🎯 Scope | 🎯 Scope |
| in_scope | In scope | In scope |
| out_scope | Out of scope | Out of scope |
| admin | ⚙️ Maintenance/Admin | ⚙️ Maintenance/Admin |
| happy | ✅ Happy Path | ✅ Happy Path |
| edge | 🧩 Edge Cases | 🧩 Edge Cases |
| scenario | 🔹 Scenario: | 🔹 Scenario: |
| steps | Stappen: | Steps: |
| expected | ➡️ Verwacht resultaat: | ➡️ Expected result: |
| assumptions | ⚠️ Aannames / bekende beperkingen | ⚠️ Assumptions / known limitations |
| admin_hint | *(instellingen die iemand in het admin-paneel moet aanpassen of controleren voordat/tijdens het testen — geen technische/developer-config)* | *(settings someone must change or check in the admin panel before/while testing — no technical/developer config)* |
| result | Resultaat: | Result: |

## Ticket templates (`/user-story`, `/refine-ticket`)

The Dutch templates in `ticket-templates.md` are canonical. For `en`, translate the headings 1:1 and keep the emoji:

| nl | en |
|---|---|
| 🎯 Doel | 🎯 Goal |
| 🧑‍💻 Werkzaamheden | 🧑‍💻 Work |
| ☑️ Acceptatiecriteria | ☑️ Acceptance criteria |
| ✅ In scope / ❌ Out of scope | ✅ In scope / ❌ Out of scope |
| 🗒️ Belangrijke notities | 🗒️ Important notes |
| Omschrijving | Description |
| Stappen om te reproduceren | Steps to reproduce |
| Verwacht resultaat / Huidig resultaat | Expected result / Actual result |
| 📦 Voorgestelde subtaken | 📦 Suggested subtasks |
| Dient meetbaar te zijn middels een GTM event | Must be measurable via a GTM event |

## Developer notes, reports and pages

| Key | nl | en |
|---|---|---|
| dev_note | 🛠 Developer note | 🛠 Developer note |
| generated_with | Gegenereerd met | Generated with |
| sources | Bronnen | Sources |
| status_draft / agreed / processed | Concept / Afgestemd met PO / Verwerkt | Draft / Agreed with PO / Processed |
| visible_for | Alleen zichtbaar voor | Only visible to |
| not_in_description | Nog niet verwerkt in de ticketbeschrijving. | Not yet processed into the ticket description. |
| open_questions | Open vragen | Open questions |
| blocking / remaining / manual | Blokkerend / Restpunten / Handmatig checken | Blocking / Remaining / Check manually |
| fe_risks_page | Sprint [naam] – FE Risico's | Sprint [name] – FE Risks |
| fe_refinement_page | Sprint [naam] – FE Refinement-agenda | Sprint [name] – FE Refinement agenda |
| growth_page | Groei-log Q[n] [jaar] | Growth log Q[n] [year] |
