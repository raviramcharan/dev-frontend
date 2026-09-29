# Platform standards

Read "General" plus only the detected platform's section.

## Contents
1. General
2. Hyvä / Magento 2
3. Shopware (Twig)
4. Shopify (Liquid)
5. Drupal

## 1. General

- **Accessibility:** semantic HTML first, ARIA only when needed. Visible focus, labels on form controls, alt text, keyboard operability for every interaction. For depth use the `wcag-audit` skill if installed.
- **Performance:** no new render-blocking scripts or stylesheets. Third-party scripts (GTM, Klaviyo, chat) deferred or on interaction. Images with `width`/`height`, `loading="lazy"` below the fold, modern formats.
- **Translatability:** no hardcoded customer-facing strings.
- **No** `console.log`, `debugger`, `var_dump`, `dump()`, `{{ dump() }}`, hardcoded domain URLs, or secrets.

## 2. Hyvä / Magento 2

- **Module namespace:** `<moduleNamespace>_<FeatureName>` (`moduleNamespace` from config), standard Magento structure (`registration.php`, `etc/module.xml`, `view/frontend/templates`, `view/frontend/layout`).
- **No RequireJS, jQuery or Knockout** in Hyvä templates. Interactivity with **Alpine.js**:
  - components as functions: `x-data="initFoo()"` with `function initFoo() { return { … } }` in a `<script>` in the `.phtml`;
  - CSP-strict projects: follow Hyvä CSP guidelines (no inline expressions that break CSP);
  - events via `$dispatch` / `window.dispatchEvent`; private content via `private-content-loaded`.
- **Styling:** Tailwind CSS v4. Utilities in markup; custom component classes only via `@utility` or `@layer components` (watch `@apply` on custom classes — behaves differently from v3). New template paths must be inside the Tailwind content sources or classes get purged. Rebuild after changes.
- **Templates (`.phtml`):** escape with `$escaper->escapeHtml()`, `escapeHtmlAttr()`, `escapeUrl()`, `escapeJs()`; translate with `__('…')`; logic in ViewModels via `$viewModels->require(…)`; icons via Hyvä `SvgIcons` / `HeroiconsOutline`.
- **Layout XML:** correct container; no `cacheable="false"` without need (breaks FPC).
- **Known Sonar false positives:** Tailwind `@utility`, anchors without `href` (use `<button>` instead — real issue), PHP Elvis `?:`. Accept false positives with a one-line justification.

## 3. Shopware (Twig)

- `{% sw_extends '@Storefront/storefront/…' %}`, override only needed `{% block %}`s, keep `{{ parent() }}` where the original must stay.
- Translate: `{{ "app.feature.label"|trans|sw_sanitize }}`, snippets in `src/Resources/snippet/<locale>/`.
- JS: Shopware JS plugins (`PluginManager.register`) registered in `main.js`; no loose inline scripts.
- SCSS in `src/Resources/app/storefront/src/scss`, theme variables instead of hardcoded colours.
- Build: `bin/build-storefront.sh` or `bin/console theme:compile`.

## 4. Shopify (Liquid)

- Sections with `{% schema %}`, snippets for reuse, JSON templates.
- Translate: `{{ 'section.feature.label' | t }}`, keys in `locales/*.json` (+ `*.schema.json` for schema labels).
- Metafields/metaobjects instead of hardcoded content.
- Images: `image_url` + `image_tag` with `widths` and `sizes`; lazy below the fold.
- JS: custom elements, `defer`; no jQuery.
- `shopify theme check` without new errors.

## 5. Drupal

- Twig templates per theme suggestions; `{{ 'Label'|t }}`; logic in preprocess (`.theme`), not the template.
- Assets via `*.libraries.yml` + `attach_library`; no inline `<script>`.
- JS: `Drupal.behaviors` with `once()`.
- Correct cache contexts/tags on render arrays; `drush cr` after template/library changes.

## Where admin-clickable settings live (for Maintenance/Admin scenarios)

| Platform | Admin surface |
|---|---|
| Magento / Hyvä | Stores → Configuration, Content → Blocks/Widgets/Pages, Catalog attributes, customer groups |
| Shopware | Plugin settings screens, Settings, Shopping Experiences (CMS), sales channel settings |
| Shopify | Theme editor (sections/blocks placement), metafield values, Navigation, Markets |
| Drupal | Module configuration forms, block layout, content types/fields, roles/permissions |
