#!/usr/bin/env bash
# dev-frontend — install, update or uninstall the Claude Code plugin via its marketplace.
#
# Usage:
#   scripts/dev-frontend.sh install   [--source <owner/repo | git-url | local-path>]
#   scripts/dev-frontend.sh update
#   scripts/dev-frontend.sh uninstall [--purge] [--remove-marketplace]
#   scripts/dev-frontend.sh lifecycle        (re)choose the optional lifecycle plugin
#   scripts/dev-frontend.sh status
#
# Env overrides: DEVFE_SOURCE, DEVFE_MARKETPLACE, DEVFE_PLUGIN

set -euo pipefail

# ---- settings -------------------------------------------------------------
SOURCE="${DEVFE_SOURCE:-raviramcharan/dev-frontend}"   # ← set your GitHub owner/repo
MARKETPLACE="${DEVFE_MARKETPLACE:-raviramcharan}"            # must match .claude-plugin/marketplace.json "name"
PLUGIN="${DEVFE_PLUGIN:-dev-frontend}"
CLAUDE_DIR="${HOME}/.claude"
CONFIG="${CLAUDE_DIR}/${PLUGIN}.json"
OLD_COMMANDS=(user-story.md test-scenarios.md)            # local commands this plugin replaces
# ---------------------------------------------------------------------------

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXAMPLE_CONFIG="${REPO_ROOT}/plugins/${PLUGIN}/config/${PLUGIN}.example.json"

say()  { printf '\033[1;34m▸\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m✗\033[0m %s\n' "$*" >&2; exit 1; }

confirm() { read -r -p "$1 [y/N] " a; [[ "$a" =~ ^[Yy]$ ]]; }

has_cli() {
  command -v claude >/dev/null 2>&1 && claude plugin --help >/dev/null 2>&1
}

manual() {
  warn "The 'claude plugin' CLI is not available in this Claude Code version."
  echo "   Run these inside Claude Code instead:"
  for line in "$@"; do echo "     $line"; done
}

install_config() {
  if [[ -f "$CONFIG" ]]; then
    say "Config exists: $CONFIG (left untouched)"
  elif [[ -f "$EXAMPLE_CONFIG" ]]; then
    mkdir -p "$CLAUDE_DIR"
    if command -v python3 >/dev/null 2>&1; then
      python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); d.pop("_readme",None); json.dump(d,open(sys.argv[2],"w"),indent=2,ensure_ascii=False)' "$EXAMPLE_CONFIG" "$CONFIG"
    else
      cp "$EXAMPLE_CONFIG" "$CONFIG"   # remove the "_readme" key by hand
    fi
    say "Personal config created: $CONFIG — review outputLanguage, devNote and growthLog"
  else
    warn "Example config not found (installed from a remote source?). Copy it from the repo: plugins/${PLUGIN}/config/"
  fi
}

detect_lifecycle() {
  # Best effort: find installed plugins that ship a dev-lifecycle skill or command.
  local roots=("${CLAUDE_DIR}/plugins") found=() f dir name
  for r in "${roots[@]}"; do
    [[ -d "$r" ]] || continue
    while IFS= read -r f; do
      dir="$f"
      while [[ "$dir" != "/" && ! -f "$dir/.claude-plugin/plugin.json" ]]; do dir="$(dirname "$dir")"; done
      [[ -f "$dir/.claude-plugin/plugin.json" ]] || continue
      name="$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1])).get("name",""))' "$dir/.claude-plugin/plugin.json" 2>/dev/null || true)"
      [[ -n "$name" && "$name" != "$PLUGIN" ]] && found+=("$name")
    done < <(find "$r" \( -path '*/skills/dev-lifecycle/SKILL.md' -o -path '*/commands/dev-lifecycle.md' \) 2>/dev/null)
  done
  printf '%s\n' "${found[@]:-}" | awk 'NF' | sort -u
}

set_lifecycle() {
  # Only when the key is absent; never overwrite a choice the user already made.
  command -v python3 >/dev/null 2>&1 || { warn "python3 not found — set \"lifecyclePlugin\" in $CONFIG by hand (or let the first command ask you)."; return; }
  if python3 -c 'import json,sys; sys.exit(0 if "lifecyclePlugin" in json.load(open(sys.argv[1])) else 1)' "$CONFIG" 2>/dev/null; then
    say "lifecyclePlugin already set in $CONFIG (left untouched)"; return
  fi
  local candidates=() c choice value
  mapfile -t candidates < <(detect_lifecycle)
  echo
  say "Lifecycle plugin (optional): a plugin providing dev-lifecycle / jira-plan / testplan / branch-review."
  if [[ ${#candidates[@]} -gt 0 ]]; then
    echo "   Detected: ${candidates[*]}"
    local i=1; for c in "${candidates[@]}"; do echo "   $i) use $c"; i=$((i+1)); done
  else
    echo "   None detected."
  fi
  echo "   t) type a namespace   s) standalone (no lifecycle plugin)   Enter) decide later (first command will ask)"
  read -r -p "   Choice: " choice
  case "$choice" in
    "" ) say "Skipped — the first command that needs it will ask."; return ;;
    s|S) value="null" ;;
    t|T) read -r -p "   Namespace: " c; [[ -z "$c" ]] && return; value="\"$c\"" ;;
    *[!0-9]*) warn "Unknown choice — skipped."; return ;;
    *) [[ "$choice" -ge 1 && "$choice" -le ${#candidates[@]} ]] || { warn "Out of range — skipped."; return; }
       value="\"${candidates[$((choice-1))]}\"" ;;
  esac
  python3 -c 'import json,sys; p=sys.argv[1]; d=json.load(open(p)); d["lifecyclePlugin"]=json.loads(sys.argv[2]); json.dump(d,open(p,"w"),indent=2,ensure_ascii=False)' "$CONFIG" "$value"
  say "lifecyclePlugin = $value"
}

old_commands() {
  local found=()
  for f in "${OLD_COMMANDS[@]}"; do [[ -f "${CLAUDE_DIR}/commands/$f" ]] && found+=("$f"); done
  [[ ${#found[@]} -eq 0 ]] && return
  warn "Old local commands found in ${CLAUDE_DIR}/commands: ${found[*]}"
  if confirm "Move them to ${CLAUDE_DIR}/commands/.backup-${PLUGIN}/ ?"; then
    mkdir -p "${CLAUDE_DIR}/commands/.backup-${PLUGIN}"
    for f in "${found[@]}"; do mv "${CLAUDE_DIR}/commands/$f" "${CLAUDE_DIR}/commands/.backup-${PLUGIN}/"; done
    say "Moved. Restore by moving them back."
  fi
}

cmd_install() {
  [[ "$SOURCE" == "<github-user>"* ]] && die "Set SOURCE in this script (or pass --source / DEVFE_SOURCE)."
  if has_cli; then
    say "Adding marketplace: $SOURCE"
    claude plugin marketplace add "$SOURCE" || warn "Marketplace may already be added — continuing."
    say "Installing ${PLUGIN}@${MARKETPLACE}"
    claude plugin install "${PLUGIN}@${MARKETPLACE}"
  else
    manual "/plugin marketplace add ${SOURCE}" "/plugin install ${PLUGIN}@${MARKETPLACE}"
  fi
  install_config
  [[ -f "$CONFIG" ]] && set_lifecycle
  old_commands
  say "Done. Restart Claude Code, then try: /${PLUGIN}:user-story <KEY>"
}

cmd_update() {
  if has_cli; then
    say "Refreshing marketplace: $MARKETPLACE"
    claude plugin marketplace update "$MARKETPLACE"
    say "Updating ${PLUGIN}@${MARKETPLACE}"
    claude plugin update "${PLUGIN}@${MARKETPLACE}" 2>/dev/null \
      || claude plugin install "${PLUGIN}@${MARKETPLACE}"
  else
    manual "/plugin marketplace update ${MARKETPLACE}" "/plugin  → Installed → ${PLUGIN} → Update"
  fi
  say "Your config ($CONFIG) is never overwritten. Compare with the example for new keys."
  say "Restart Claude Code to load the new version."
}

cmd_uninstall() {
  local purge=false rm_mp=false
  for a in "$@"; do
    case "$a" in --purge) purge=true ;; --remove-marketplace) rm_mp=true ;; esac
  done
  if has_cli; then
    say "Uninstalling ${PLUGIN}@${MARKETPLACE}"
    claude plugin uninstall "${PLUGIN}@${MARKETPLACE}" || warn "Plugin was not installed."
    if $rm_mp; then
      say "Removing marketplace: $MARKETPLACE"
      claude plugin marketplace remove "$MARKETPLACE" || warn "Marketplace was not added."
    fi
  else
    local steps=("/plugin uninstall ${PLUGIN}@${MARKETPLACE}")
    $rm_mp && steps+=("/plugin marketplace remove ${MARKETPLACE}")
    manual "${steps[@]}"
  fi
  if $purge && [[ -f "$CONFIG" ]]; then
    confirm "Delete personal config $CONFIG ?" && rm "$CONFIG" && say "Config deleted."
  else
    say "Personal config kept: $CONFIG (use --purge to remove)."
  fi
  say "Not touched: Jira developer notes, Confluence pages, agent_docs/*/fe-gate.md, .fe-checks.log, project .claude/${PLUGIN}.json files."
}

cmd_lifecycle() {
  [[ -f "$CONFIG" ]] || install_config
  [[ -f "$CONFIG" ]] || die "No config at $CONFIG."
  python3 -c 'import json,sys; p=sys.argv[1]; d=json.load(open(p)); d.pop("lifecyclePlugin",None); json.dump(d,open(p,"w"),indent=2,ensure_ascii=False)' "$CONFIG"
  set_lifecycle
}

cmd_status() {
  if has_cli; then
    claude plugin marketplace list 2>/dev/null | grep -i "$MARKETPLACE" || echo "marketplace '$MARKETPLACE' not added"
    claude plugin list 2>/dev/null | grep -i "$PLUGIN" || echo "plugin '$PLUGIN' not installed"
  else
    manual "/plugin  → Installed / Marketplaces"
  fi
  [[ -f "$CONFIG" ]] && echo "config: $CONFIG" || echo "config: none"
}

ARGS=()
action="${1:-}"; shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --source) SOURCE="$2"; shift 2 ;;
    *) ARGS+=("$1"); shift ;;
  esac
done
case "$action" in
  install)   cmd_install ;;
  update)    cmd_update ;;
  uninstall) cmd_uninstall "${ARGS[@]:-}" ;;
  lifecycle) cmd_lifecycle ;;
  status)    cmd_status ;;
  *) sed -n '2,11p' "$0"; exit 1 ;;
esac
