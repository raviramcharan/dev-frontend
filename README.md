# dev-frontend

A Claude Code plugin for front-end work on Jira-based e-commerce projects (Hyvä/Magento 2, Shopware, Shopify, Drupal). From a well-written ticket to a verified delivery — with every result previewed first and posted to Jira only after your approval.

## Commands

| Command | What it does |
|---|---|
| `/dev-frontend:user-story <KEY>` | Rewrites a ticket into a paste-ready template (Compact, Extended or Bug) |
| `/dev-frontend:refine-ticket <KEY>` | Definition of Ready score + open questions per role, as a developer note |
| `/dev-frontend:start-branch <KEY>` | Creates the branch by convention and asks which base to branch off |
| `/dev-frontend:test-scenarios [KEY]` | Test matrix from the diff: Maintenance/Admin, Happy Path, Edge Cases |
| `/dev-frontend:fe-gate [KEY]` | FE quality gate: acceptance criteria, WCAG, Core Web Vitals, translations → go/no-go |
| `/dev-frontend:jira-sync [KEY]` | Posts plans, test plans and gate reports to Jira as developer notes |
| `/dev-frontend:sprint-risks` | Readiness, risks and dependencies per sprint, published to Confluence |
| `/dev-frontend:growth-log summary` | Quarterly overview of risks you flagged early |

Output is Dutch by default; set `outputLanguage` to `en` or `auto`, or add `--lang en` to any command.

## Requirements

- Claude Code with plugin support
- The official Atlassian MCP server (Jira + Confluence):

  ```bash
  claude mcp add --transport http atlassian https://mcp.atlassian.com/v1/mcp
  ```

  Then run `/mcp` in Claude Code and sign in to Atlassian. The commands use its tool names (`getJiraIssue`, `addCommentToJiraIssue`, …); community Jira servers name their tools differently and may not work reliably.

Without the MCP, `test-scenarios` and `fe-gate` still work from `agent_docs/<KEY>/issue.md` and the diff, `start-branch` still creates the branch, and `growth-log` works with `location: "local"`. `jira-sync` and `sprint-risks` need it.

## Installation

In Claude Code:

```
/plugin marketplace add raviramcharan/dev-frontend
/plugin install dev-frontend@raviramcharan
```

Or with the script, which also creates your config:

```bash
git clone https://github.com/raviramcharan/dev-frontend.git
cd dev-frontend
scripts/dev-frontend.sh install
```

Restart Claude Code afterwards.

## Configuration

Copy [`config/dev-frontend.example.json`](plugins/dev-frontend/config/dev-frontend.example.json) to `~/.claude/dev-frontend.json` (the script does this for you). Per project, you can override values in `<repo>/.claude/dev-frontend.json`.

The keys you'll most likely change:

| Key | Purpose |
|---|---|
| `outputLanguage` | `nl`, `en` or `auto` (follows the ticket's language) |
| `devNote.visibility` | Jira role or group that can see developer notes (default: role `Developers`) |
| `branches.sprintBranchPatterns` | Which branches are offered as a base, besides `develop` |

Jira restricts comments to a role or group, not a single person. If the visibility can't be applied, nothing gets posted.

### Lifecycle plugin (optional)

`dev-frontend` can work alongside a plugin that manages the dev lifecycle (skills like `dev-lifecycle`, `jira-plan`, `testplan`, `branch-review` writing to `agent_docs/`). You don't need to configure this yourself: the first command that needs it detects installed plugins and asks whether to use one — for all projects, only this project, or not at all. The install script asks the same question.

To change your answer later, run `scripts/dev-frontend.sh lifecycle`, or set `lifecyclePlugin` in your config to a namespace or `null`.

## Updating

```
/plugin marketplace update raviramcharan
```

Then update `dev-frontend` via `/plugin` → Installed. Or run `scripts/dev-frontend.sh update`. Your config files are never overwritten.

## Uninstalling

```
/plugin uninstall dev-frontend@raviramcharan
/plugin marketplace remove raviramcharan
```

Or run `scripts/dev-frontend.sh uninstall`. Add `--purge` to remove your config as well. Notes in Jira and pages in Confluence stay where they are.

## More

- [Guide](plugins/dev-frontend/GUIDE.md): when to use what, a worked example, troubleshooting
- [Changelog](plugins/dev-frontend/CHANGELOG.md)
