#!/usr/bin/env bash
#
# inject-mcp-token.sh
#
# Replace the ${user_config.zai_api_token} placeholders in the installed plugin's
# .mcp.json with the value of the ZAI_MCP_TOKEN environment variable.
#
# Background: the recommended path is the userConfig field (auto-replaced by
# ZCode). This script is a fallback for environments where userConfig expansion
# is unavailable. It substitutes the placeholder that userConfig would have
# expanded.
#
# Usage:
#   export ZAI_MCP_TOKEN=your_zhipu_api_key
#   bash scripts/inject-mcp-token.sh            # auto-detect latest installed version
#   bash scripts/inject-mcp-token.sh 1.0.2      # target a specific version
#
# Behavior:
#   - Reads token from $ZAI_MCP_TOKEN (errors out if missing/empty)
#   - Locates the newest installed x.y.z version dir (or uses the one passed in)
#   - Backs up .mcp.json to .mcp.json.bak before editing
#   - Idempotent: a file with no placeholder is treated as success (no rewrite)
#   - Escapes token chars that are special to sed (backslash, &, /)
#   - Cross-platform: works on macOS BSD sed and GNU sed
#
set -euo pipefail

# ----------------------------- config -----------------------------
PLUGIN_NAME="annopick-plugin"
PLUGIN_GROUP="annopick-plugin"
PLACEHOLDER='${user_config.zai_api_token}'
INSTALL_ROOT="$HOME/.zcode/cli/plugins/cache/${PLUGIN_GROUP}/${PLUGIN_NAME}"

# ----------------------------- color -----------------------------
if [ -t 1 ]; then
    GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; RESET=$'\033[0m'
else
    GREEN=''; YELLOW=''; RED=''; RESET=''
fi

ok()   { printf '%s%s%s\n' "$GREEN"  "$*" "$RESET"; }
warn() { printf '%s%s%s\n' "$YELLOW" "$*" "$RESET" >&2; }
err()  { printf '%s%s%s\n' "$RED"    "$*" "$RESET" >&2; }

# ----------------------------- validate token -----------------------------
if [ -z "${ZAI_MCP_TOKEN:-}" ]; then
    err "Error: env var ZAI_MCP_TOKEN is not set or empty."
    err "Run: export ZAI_MCP_TOKEN=<your zhipu api key>"
    err "(add it to ~/.zshrc or ~/.bashrc to persist across sessions)"
    exit 1
fi

# ----------------------------- locate plugin dir -----------------------------
if [ ! -d "$INSTALL_ROOT" ]; then
    err "Error: plugin install dir not found: $INSTALL_ROOT"
    err "Please install the plugin in the ZCode client first, then re-run this script."
    exit 1
fi

if [ $# -ge 1 ]; then
    VERSION="$1"
else
    VERSION=$(ls -1 "$INSTALL_ROOT" 2>/dev/null \
        | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
        | sort -V \
        | tail -1 || true)
    if [ -z "$VERSION" ]; then
        err "Error: no version directory (x.y.z) found under $INSTALL_ROOT."
        err "Make sure the plugin is fully installed; or pass the version explicitly:"
        err "  bash $0 1.0.2"
        exit 1
    fi
fi

VERSION_DIR="$INSTALL_ROOT/$VERSION"
MCP_FILE="$VERSION_DIR/.mcp.json"

if [ ! -f "$MCP_FILE" ]; then
    err "Error: target file not found: $MCP_FILE"
    err "Check that version ($VERSION) is correct and the plugin is fully installed."
    exit 1
fi

printf 'Target version: %s\n' "$VERSION"
printf 'Target file:    %s\n' "$MCP_FILE"

# ----------------------------- idempotency check -----------------------------
# grep returns 1 when nothing matched; guard with || true so set -e does not abort.
if ! grep -qF -- "$PLACEHOLDER" "$MCP_FILE"; then
    warn "Note: placeholder $PLACEHOLDER not found; file looks already substituted. Nothing to do."
    ok "Done (no changes)."
    exit 0
fi

# ----------------------------- backup -----------------------------
BACKUP="$MCP_FILE.bak"
cp -f "$MCP_FILE" "$BACKUP"
printf 'Backup:         %s\n' "$BACKUP"

# ----------------------------- perform replacement -----------------------------
# Use bash parameter expansion (${var//find/replace}) which is pure literal
# string replacement — no regex, no escaping. Robust to any char in the token
# (/ & \ etc.). Newline style (LF/CRLF) and trailing newline are preserved
# because we read raw lines and re-emit them verbatim.
TMP_FILE="${MCP_FILE}.tmp"
: > "$TMP_FILE"
while IFS= read -r line || [ -n "$line" ]; do
    printf '%s\n' "${line//"$PLACEHOLDER"/"$ZAI_MCP_TOKEN"}" >> "$TMP_FILE"
done < "$MCP_FILE"
mv -f "$TMP_FILE" "$MCP_FILE"

# ----------------------------- verify -----------------------------
if grep -qF -- "$PLACEHOLDER" "$MCP_FILE"; then
    err "Error: placeholder still present after substitution; backup kept at $BACKUP for rollback."
    exit 1
fi

COUNT=$(grep -cF -- "$ZAI_MCP_TOKEN" "$MCP_FILE" || true)
ok "Substitution OK: $COUNT occurrence(s) written."
ok "Done."
