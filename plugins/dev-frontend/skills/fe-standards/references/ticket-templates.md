# Ticket templates

Canonical templates (Dutch). For output language `en`, translate headings via `output-language.md`; keep structure and emoji identical.

## Main task vs subtask vs bug

Combine both signals:
- **Subtask** if `issuetype.subtask == true` AND/OR a `parent` field is present.
- **Main task** if neither applies.
- **Bug** overrides this: issuetype "Bug" → always the Bug template, main task or subtask.
- Conflicting signals (parent present, issuetype not marked subtask) → treat as subtask; the parent relation decides.

## Decision rules — which template

- **Bug** → always the Bug template, regardless of complexity. Recognise a bug by: something doesn't work as expected, an error, a regression, "this is wrong", "this is broken", etc.
- **Simple task** (reasonably doable within ±8 hours, limited scope, no architectural impact) → Compact.
- **Complex task** (multiple components, dependencies, platform impact, more than ±8 hours) → Uitgebreid.
- **Subtask** → usually Compact, unless the subtask itself spans >±8 hours or multiple components.

If it's unclear whether a task is compact or extended and the ticket gives too little to judge, ask **one** focused question instead of guessing.

## Template 1 – Compact (simple task, ≤ ±8 hours)

```
## 🎯 Doel
[1 zin: wat moet er concreet bereikt worden]

## 🧑‍💻 Werkzaamheden
- [Concreet punt 1]
- [Concreet punt 2]
- [Optioneel punt 3]

## ☑️ Acceptatiecriteria
- [Objectief controleerbaar criterium 1]
- [Eventueel criterium 2]
- [Maximaal 3 criteria]
- [Dient meetbaar te zijn middels een GTM event]
```

## Template 2 – Uitgebreid (complex task, > ±8 hours)

```
# TL;DR
[Een beknopte samenvatting van alles wat hieronder staat.]

# 🎯 Doel
[SMART-geformuleerd doel. Tijdsgebonden is niet relevant.]

# ✅ In scope
- [Taak binnen scope]

# ❌ Out of scope
- [Taak buiten scope]

# ☑️ Acceptatiecriteria
- [Objectief controleerbaar criterium]
- [Dient meetbaar te zijn middels een GTM event]

# 🗒️ Belangrijke notities
- [Relevante notities, URLs indien aangeleverd]
```

## Template 3 – Bug (always for bugs)

```
# Omschrijving
[Korte, feitelijke beschrijving van het probleem in 1-2 zinnen.]

# Stappen om te reproduceren
1. [Stap 1]
2. [Stap 2]
3. [Stap 3]

# Verwacht resultaat
[Wat zou er moeten gebeuren]

# Huidig resultaat
[Wat gebeurt er nu]

# Context
- URL: [omgeving]
- Device / browser: [indien relevant]
- Overige relevante info: [optioneel]
```

## Suggested subtasks — main tasks only

Always append after the template for a main task (text only, to copy — never create these subtasks in Jira):

```
## 📦 Voorgestelde subtaken

### FE — [voorgestelde titel]
[1-2 zinnen scope van het frontend-werk]

### BE — [voorgestelde titel]
[1-2 zinnen scope van het backend-werk]
```

Omit FE or BE only when the main task obviously needs no work in that discipline — say so briefly instead of inventing a forced suggestion.

## Optional test plan — only when explicitly asked with "Maak een testplan"

```
# 🧑‍🔬 Testinstructies

**Testplan**
Ga naar ⟶ [omgeving URL]
Scroll naar de relevante sectie of pagina
Bekijk en beoordeel het desktop design. Vergelijk met het Figma ontwerp
Druk op F12 (⌘ + Option + i) ⟶ open developer tools
Druk op CTRL + SHIFT + M (⌘ + SHIFT + M) ⟶ mobile mode
Bekijk en beoordeel het mobile design. Vergelijk met het Figma ontwerp

**Beheer / Admin**
Ga naar ⟶ [admin URL] en log in met je admin account
Voer de relevante acties uit
Controleer dat wijzigingen zichtbaar zijn in de frontend

**Verwacht resultaat**
[Beschrijf per stap wat het resultaat moet zijn]
```

(For `en` the trigger phrase "Make a test plan" works too.)

## Writing rules (all templates)

- No abstract descriptions; add only what improves understanding.
- Never invent facts not derivable from the ticket content.
- No empty sections.
- Jira-compatible Markdown (`#` headings, `-` list items).
- Default platform is Hyvä (Magento) unless stated otherwise. Mobile-friendly is always an implicit requirement: don't mention it separately unless the ticket asks, but acceptance criteria must never contradict it.
